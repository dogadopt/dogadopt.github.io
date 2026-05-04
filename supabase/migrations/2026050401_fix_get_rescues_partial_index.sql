-- Fix get_rescues() performance: add partial index for the dog-count subquery.
--
-- The composite index (rescue_id, status) added in 2026032301 uses the wrong
-- column order for the count subquery inside get_rescues():
--
--   SELECT rescue_id, COUNT(*) AS cnt
--   FROM dogadopt.dogs
--   WHERE status = 'available'
--   GROUP BY rescue_id
--
-- PostgreSQL filters on status first, then aggregates by rescue_id.  With a
-- (rescue_id, status) index the planner must scan every rescue_id bucket and
-- filter on status within each — it may fall back to a sequential scan when
-- cardinality estimates make that cheaper.
--
-- A partial index on (rescue_id) WHERE status = 'available' is:
--   • Smaller  — only available-dog rows are indexed.
--   • Unambiguous — the WHERE clause matches the query predicate exactly, so
--     the planner always prefers it over a full-table scan.

CREATE INDEX IF NOT EXISTS idx_dogs_available_by_rescue
  ON dogadopt.dogs (rescue_id)
  WHERE status = 'available'::dogadopt.adoption_status;

COMMENT ON INDEX dogadopt.idx_dogs_available_by_rescue IS
  'Partial index for the available-dog COUNT in dogadopt_api.get_rescues(). '
  'Covers WHERE status = ''available'' GROUP BY rescue_id without a seq scan.';

-- Refresh statistics so the planner uses the new index immediately.
ANALYZE dogadopt.dogs;
