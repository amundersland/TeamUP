-- ============================================================
-- TeamUP Database Schema — Test Suite
-- PostgreSQL
--
-- All operations run inside a single transaction that is rolled
-- back at the end, leaving the database unchanged.
--
-- Usage:
--   psql -U <user> -d <db> -f db-schema/schema.sql
--   psql -U <user> -d <db> -f db-schema/test.sql
--
-- Expected output: 17 "PASSED" notices followed by
--   "ALL 17 TESTS PASSED"
-- ============================================================

BEGIN;
SET LOCAL search_path TO teamup;

DO $$
DECLARE
    -- Shared lookup IDs (never deleted during the test run)
    v_lmt_id    INTEGER;   -- learning_material_type
    v_lpt_id    INTEGER;   -- learning_path_type

    -- Entity IDs (some are re-created between cascade tests)
    v_tag_id    INTEGER;
    v_tag2_id   INTEGER;
    v_wn_id     INTEGER;   -- wiki_note
    v_wn2_id    INTEGER;
    v_emp_id    INTEGER;
    v_lm_id     INTEGER;
    v_lp_id     INTEGER;
    v_eg_id     INTEGER;

    -- Assertion helpers
    v_count     INTEGER;
    v_arr_len   INTEGER;
    v_jlen      INTEGER;
    v_raised    BOOLEAN;
    v_bool      BOOLEAN;
BEGIN

    -- ============================================================
    -- SETUP: shared lookup rows used across all tests
    -- ============================================================
    INSERT INTO learning_material_type (name) VALUES ('Book')          RETURNING id INTO v_lmt_id;
    INSERT INTO learning_path_type     (name) VALUES ('Certification') RETURNING id INTO v_lpt_id;

    -- ============================================================
    -- TEST 1: Basic inserts into every entity and lookup table
    -- ============================================================
    INSERT INTO tag           (name, description)         VALUES ('Backend',      'Backend technology') RETURNING id INTO v_tag_id;
    INSERT INTO wiki_note     (title, body)               VALUES ('Setup Guide',  'How to get started') RETURNING id INTO v_wn_id;
    INSERT INTO employee      (fullname, job_title, age)  VALUES ('Alice Smith',  'Engineer', 30)       RETURNING id INTO v_emp_id;
    INSERT INTO learning_material (name, description, link, price, type_id)
        VALUES ('PostgreSQL Guide', 'Comprehensive guide', 'http://example.com', 50, v_lmt_id)          RETURNING id INTO v_lm_id;
    INSERT INTO learning_path (name, type_id)             VALUES ('DB Path',      v_lpt_id)             RETURNING id INTO v_lp_id;
    INSERT INTO employee_group (groupname, purpose)       VALUES ('Backend Team', 'Backend devs')       RETURNING id INTO v_eg_id;

    SELECT COUNT(*) INTO v_count FROM tag                  WHERE id = v_tag_id;  IF v_count <> 1 THEN RAISE EXCEPTION 'TEST 1 FAILED: tag insert';                  END IF;
    SELECT COUNT(*) INTO v_count FROM wiki_note            WHERE id = v_wn_id;   IF v_count <> 1 THEN RAISE EXCEPTION 'TEST 1 FAILED: wiki_note insert';             END IF;
    SELECT COUNT(*) INTO v_count FROM learning_material_type WHERE id = v_lmt_id; IF v_count <> 1 THEN RAISE EXCEPTION 'TEST 1 FAILED: learning_material_type insert'; END IF;
    SELECT COUNT(*) INTO v_count FROM learning_path_type   WHERE id = v_lpt_id;  IF v_count <> 1 THEN RAISE EXCEPTION 'TEST 1 FAILED: learning_path_type insert';    END IF;
    SELECT COUNT(*) INTO v_count FROM employee             WHERE id = v_emp_id;  IF v_count <> 1 THEN RAISE EXCEPTION 'TEST 1 FAILED: employee insert';              END IF;
    SELECT COUNT(*) INTO v_count FROM learning_material    WHERE id = v_lm_id;   IF v_count <> 1 THEN RAISE EXCEPTION 'TEST 1 FAILED: learning_material insert';     END IF;
    SELECT COUNT(*) INTO v_count FROM learning_path        WHERE id = v_lp_id;   IF v_count <> 1 THEN RAISE EXCEPTION 'TEST 1 FAILED: learning_path insert';         END IF;
    SELECT COUNT(*) INTO v_count FROM employee_group       WHERE id = v_eg_id;   IF v_count <> 1 THEN RAISE EXCEPTION 'TEST 1 FAILED: employee_group insert';        END IF;

    RAISE NOTICE 'TEST 1 PASSED: Basic inserts into all tables';

    -- ============================================================
    -- TEST 2: tag_ids array population and length check
    -- ============================================================
    INSERT INTO tag (name) VALUES ('Frontend') RETURNING id INTO v_tag2_id;

    UPDATE learning_material SET tag_ids = ARRAY[v_tag_id, v_tag2_id] WHERE id = v_lm_id;
    UPDATE learning_path     SET tag_ids = ARRAY[v_tag_id]            WHERE id = v_lp_id;
    UPDATE employee_group    SET tag_ids = ARRAY[v_tag_id]            WHERE id = v_eg_id;

    SELECT array_length(tag_ids, 1) INTO v_arr_len FROM learning_material WHERE id = v_lm_id;
    IF v_arr_len <> 2 THEN RAISE EXCEPTION 'TEST 2 FAILED: learning_material tag_ids — expected 2, got %', v_arr_len; END IF;
    SELECT array_length(tag_ids, 1) INTO v_arr_len FROM learning_path     WHERE id = v_lp_id;
    IF v_arr_len <> 1 THEN RAISE EXCEPTION 'TEST 2 FAILED: learning_path tag_ids — expected 1, got %',     v_arr_len; END IF;
    SELECT array_length(tag_ids, 1) INTO v_arr_len FROM employee_group    WHERE id = v_eg_id;
    IF v_arr_len <> 1 THEN RAISE EXCEPTION 'TEST 2 FAILED: employee_group tag_ids — expected 1, got %',    v_arr_len; END IF;

    RAISE NOTICE 'TEST 2 PASSED: tag_ids array population and length';

    -- ============================================================
    -- TEST 3: wiki_note_ids array population and length check
    -- ============================================================
    INSERT INTO wiki_note (title, body) VALUES ('Advanced Topics', 'Deep dive') RETURNING id INTO v_wn2_id;

    UPDATE learning_material SET wiki_note_ids = ARRAY[v_wn_id, v_wn2_id] WHERE id = v_lm_id;
    UPDATE learning_path     SET wiki_note_ids = ARRAY[v_wn_id]            WHERE id = v_lp_id;
    UPDATE employee_group    SET wiki_note_ids = ARRAY[v_wn_id]            WHERE id = v_eg_id;

    SELECT array_length(wiki_note_ids, 1) INTO v_arr_len FROM learning_material WHERE id = v_lm_id;
    IF v_arr_len <> 2 THEN RAISE EXCEPTION 'TEST 3 FAILED: learning_material wiki_note_ids — expected 2, got %', v_arr_len; END IF;
    SELECT array_length(wiki_note_ids, 1) INTO v_arr_len FROM learning_path     WHERE id = v_lp_id;
    IF v_arr_len <> 1 THEN RAISE EXCEPTION 'TEST 3 FAILED: learning_path wiki_note_ids — expected 1, got %',     v_arr_len; END IF;
    SELECT array_length(wiki_note_ids, 1) INTO v_arr_len FROM employee_group    WHERE id = v_eg_id;
    IF v_arr_len <> 1 THEN RAISE EXCEPTION 'TEST 3 FAILED: employee_group wiki_note_ids — expected 1, got %',    v_arr_len; END IF;

    RAISE NOTICE 'TEST 3 PASSED: wiki_note_ids array population and length';

    -- ============================================================
    -- TEST 4: Inline notes JSONB storage and length check
    -- ============================================================
    UPDATE learning_material SET notes = '[{"text":"pg note"},{"text":"second note"}]' WHERE id = v_lm_id;
    UPDATE learning_path     SET notes = '[{"text":"path note"}]'                      WHERE id = v_lp_id;
    UPDATE employee_group    SET notes = '[{"text":"group note"}]'                     WHERE id = v_eg_id;

    SELECT jsonb_array_length(notes) INTO v_jlen FROM learning_material WHERE id = v_lm_id;
    IF v_jlen <> 2 THEN RAISE EXCEPTION 'TEST 4 FAILED: learning_material notes length — expected 2, got %', v_jlen; END IF;
    SELECT jsonb_array_length(notes) INTO v_jlen FROM learning_path     WHERE id = v_lp_id;
    IF v_jlen <> 1 THEN RAISE EXCEPTION 'TEST 4 FAILED: learning_path notes length — expected 1, got %',     v_jlen; END IF;
    SELECT jsonb_array_length(notes) INTO v_jlen FROM employee_group    WHERE id = v_eg_id;
    IF v_jlen <> 1 THEN RAISE EXCEPTION 'TEST 4 FAILED: employee_group notes length — expected 1, got %',    v_jlen; END IF;

    RAISE NOTICE 'TEST 4 PASSED: Inline notes JSONB storage and length';

    -- ============================================================
    -- TEST 5: All 6 binding table inserts
    -- ============================================================
    INSERT INTO employee_has_learning_path          (employee_id, learning_path_id)           VALUES (v_emp_id, v_lp_id);
    INSERT INTO employee_has_learning_material      (employee_id, learning_material_id)       VALUES (v_emp_id, v_lm_id);
    INSERT INTO learning_path_has_learning_material (learning_path_id, learning_material_id)  VALUES (v_lp_id,  v_lm_id);
    INSERT INTO employee_group_has_employee         (employee_group_id, employee_id)          VALUES (v_eg_id,  v_emp_id);
    INSERT INTO employee_group_has_learning_path    (employee_group_id, learning_path_id)     VALUES (v_eg_id,  v_lp_id);
    INSERT INTO employee_group_has_learning_material(employee_group_id, learning_material_id) VALUES (v_eg_id,  v_lm_id);

    SELECT COUNT(*) INTO v_count FROM employee_has_learning_path          WHERE employee_id      = v_emp_id AND learning_path_id     = v_lp_id; IF v_count <> 1 THEN RAISE EXCEPTION 'TEST 5 FAILED: employee_has_learning_path';          END IF;
    SELECT COUNT(*) INTO v_count FROM employee_has_learning_material      WHERE employee_id      = v_emp_id AND learning_material_id = v_lm_id; IF v_count <> 1 THEN RAISE EXCEPTION 'TEST 5 FAILED: employee_has_learning_material';      END IF;
    SELECT COUNT(*) INTO v_count FROM learning_path_has_learning_material WHERE learning_path_id = v_lp_id  AND learning_material_id = v_lm_id; IF v_count <> 1 THEN RAISE EXCEPTION 'TEST 5 FAILED: learning_path_has_learning_material'; END IF;
    SELECT COUNT(*) INTO v_count FROM employee_group_has_employee         WHERE employee_group_id = v_eg_id AND employee_id          = v_emp_id; IF v_count <> 1 THEN RAISE EXCEPTION 'TEST 5 FAILED: employee_group_has_employee';         END IF;
    SELECT COUNT(*) INTO v_count FROM employee_group_has_learning_path    WHERE employee_group_id = v_eg_id AND learning_path_id     = v_lp_id;  IF v_count <> 1 THEN RAISE EXCEPTION 'TEST 5 FAILED: employee_group_has_learning_path';    END IF;
    SELECT COUNT(*) INTO v_count FROM employee_group_has_learning_material WHERE employee_group_id = v_eg_id AND learning_material_id = v_lm_id; IF v_count <> 1 THEN RAISE EXCEPTION 'TEST 5 FAILED: employee_group_has_learning_material'; END IF;

    RAISE NOTICE 'TEST 5 PASSED: All 6 binding table inserts verified';

    -- ============================================================
    -- TEST 6: Trigger — delete tag cascades to tag_ids arrays
    --
    -- State before: learning_material.tag_ids = [v_tag_id, v_tag2_id]
    -- Deleting v_tag2_id (Frontend) must remove it from arrays.
    -- ============================================================
    DELETE FROM tag WHERE id = v_tag2_id;

    SELECT (v_tag2_id = ANY(tag_ids)) INTO v_bool FROM learning_material WHERE id = v_lm_id;
    IF COALESCE(v_bool, FALSE) THEN
        RAISE EXCEPTION 'TEST 6 FAILED: deleted tag_id still present in learning_material.tag_ids';
    END IF;
    SELECT (v_tag2_id = ANY(tag_ids)) INTO v_bool FROM learning_path     WHERE id = v_lp_id;
    IF COALESCE(v_bool, FALSE) THEN
        RAISE EXCEPTION 'TEST 6 FAILED: deleted tag_id still present in learning_path.tag_ids';
    END IF;
    SELECT (v_tag2_id = ANY(tag_ids)) INTO v_bool FROM employee_group    WHERE id = v_eg_id;
    IF COALESCE(v_bool, FALSE) THEN
        RAISE EXCEPTION 'TEST 6 FAILED: deleted tag_id still present in employee_group.tag_ids';
    END IF;

    RAISE NOTICE 'TEST 6 PASSED: Delete tag cascades to all tag_ids arrays';

    -- ============================================================
    -- TEST 7: Trigger — delete wiki_note cascades to wiki_note_ids arrays
    --
    -- State before: learning_material.wiki_note_ids = [v_wn_id, v_wn2_id]
    -- Deleting v_wn2_id (Advanced Topics) must remove it from arrays.
    -- ============================================================
    DELETE FROM wiki_note WHERE id = v_wn2_id;

    SELECT (v_wn2_id = ANY(wiki_note_ids)) INTO v_bool FROM learning_material WHERE id = v_lm_id;
    IF COALESCE(v_bool, FALSE) THEN
        RAISE EXCEPTION 'TEST 7 FAILED: deleted wiki_note_id still present in learning_material.wiki_note_ids';
    END IF;
    SELECT (v_wn2_id = ANY(wiki_note_ids)) INTO v_bool FROM learning_path     WHERE id = v_lp_id;
    IF COALESCE(v_bool, FALSE) THEN
        RAISE EXCEPTION 'TEST 7 FAILED: deleted wiki_note_id still present in learning_path.wiki_note_ids';
    END IF;
    SELECT (v_wn2_id = ANY(wiki_note_ids)) INTO v_bool FROM employee_group    WHERE id = v_eg_id;
    IF COALESCE(v_bool, FALSE) THEN
        RAISE EXCEPTION 'TEST 7 FAILED: deleted wiki_note_id still present in employee_group.wiki_note_ids';
    END IF;

    RAISE NOTICE 'TEST 7 PASSED: Delete wiki_note cascades to all wiki_note_ids arrays';

    -- ============================================================
    -- TEST 8: CASCADE DELETE — deleting an employee removes all
    -- binding rows that reference that employee.
    -- ============================================================
    DELETE FROM employee WHERE id = v_emp_id;

    SELECT COUNT(*) INTO v_count FROM employee_has_learning_path      WHERE employee_id = v_emp_id;
    IF v_count <> 0 THEN RAISE EXCEPTION 'TEST 8 FAILED: employee_has_learning_path still has % row(s)', v_count; END IF;
    SELECT COUNT(*) INTO v_count FROM employee_has_learning_material  WHERE employee_id = v_emp_id;
    IF v_count <> 0 THEN RAISE EXCEPTION 'TEST 8 FAILED: employee_has_learning_material still has % row(s)', v_count; END IF;
    SELECT COUNT(*) INTO v_count FROM employee_group_has_employee     WHERE employee_id = v_emp_id;
    IF v_count <> 0 THEN RAISE EXCEPTION 'TEST 8 FAILED: employee_group_has_employee still has % row(s)', v_count; END IF;

    RAISE NOTICE 'TEST 8 PASSED: CASCADE DELETE employee clears all binding rows';

    -- ============================================================
    -- TEST 9: CASCADE DELETE — deleting a learning_path removes all
    -- binding rows that reference that learning_path.
    --
    -- Re-insert an employee (Alice was deleted in TEST 8).
    -- binding rows from TEST 5 that involve v_lp_id are still present:
    --   employee_group_has_learning_path (v_eg_id, v_lp_id)
    --   learning_path_has_learning_material (v_lp_id, v_lm_id)
    -- Also add a fresh employee → learning_path binding.
    -- ============================================================
    INSERT INTO employee (fullname, age) VALUES ('Bob Jones', 28) RETURNING id INTO v_emp_id;
    INSERT INTO employee_has_learning_path (employee_id, learning_path_id) VALUES (v_emp_id, v_lp_id);

    DELETE FROM learning_path WHERE id = v_lp_id;

    SELECT COUNT(*) INTO v_count FROM employee_has_learning_path         WHERE learning_path_id = v_lp_id;
    IF v_count <> 0 THEN RAISE EXCEPTION 'TEST 9 FAILED: employee_has_learning_path still has % row(s)', v_count; END IF;
    SELECT COUNT(*) INTO v_count FROM employee_group_has_learning_path   WHERE learning_path_id = v_lp_id;
    IF v_count <> 0 THEN RAISE EXCEPTION 'TEST 9 FAILED: employee_group_has_learning_path still has % row(s)', v_count; END IF;
    SELECT COUNT(*) INTO v_count FROM learning_path_has_learning_material WHERE learning_path_id = v_lp_id;
    IF v_count <> 0 THEN RAISE EXCEPTION 'TEST 9 FAILED: learning_path_has_learning_material still has % row(s)', v_count; END IF;

    RAISE NOTICE 'TEST 9 PASSED: CASCADE DELETE learning_path clears all binding rows';

    -- ============================================================
    -- TEST 10: CASCADE DELETE — deleting a learning_material removes
    -- all binding rows that reference that learning_material.
    --
    -- Re-insert a learning_path (deleted in TEST 9).
    -- Remaining binding rows involving v_lm_id:
    --   employee_group_has_learning_material (v_eg_id, v_lm_id) from TEST 5
    -- Add fresh employee and path bindings before deleting.
    -- ============================================================
    INSERT INTO learning_path (name, type_id) VALUES ('New Path', v_lpt_id) RETURNING id INTO v_lp_id;
    INSERT INTO employee_has_learning_material       (employee_id, learning_material_id)       VALUES (v_emp_id, v_lm_id);
    INSERT INTO learning_path_has_learning_material  (learning_path_id, learning_material_id)  VALUES (v_lp_id,  v_lm_id);
    -- employee_group_has_learning_material (v_eg_id, v_lm_id) still exists from TEST 5.

    DELETE FROM learning_material WHERE id = v_lm_id;

    SELECT COUNT(*) INTO v_count FROM employee_has_learning_material       WHERE learning_material_id = v_lm_id;
    IF v_count <> 0 THEN RAISE EXCEPTION 'TEST 10 FAILED: employee_has_learning_material still has % row(s)', v_count; END IF;
    SELECT COUNT(*) INTO v_count FROM employee_group_has_learning_material WHERE learning_material_id = v_lm_id;
    IF v_count <> 0 THEN RAISE EXCEPTION 'TEST 10 FAILED: employee_group_has_learning_material still has % row(s)', v_count; END IF;
    SELECT COUNT(*) INTO v_count FROM learning_path_has_learning_material  WHERE learning_material_id = v_lm_id;
    IF v_count <> 0 THEN RAISE EXCEPTION 'TEST 10 FAILED: learning_path_has_learning_material still has % row(s)', v_count; END IF;

    RAISE NOTICE 'TEST 10 PASSED: CASCADE DELETE learning_material clears all binding rows';

    -- ============================================================
    -- TEST 11: CASCADE DELETE — deleting an employee_group removes
    -- all binding rows that reference that employee_group.
    --
    -- Insert a fresh learning_material (v_lm_id was deleted in TEST 10)
    -- then populate all 3 group binding tables before deleting the group.
    -- ============================================================
    INSERT INTO learning_material (name, type_id) VALUES ('Test Material', v_lmt_id) RETURNING id INTO v_lm_id;
    INSERT INTO employee_group_has_employee          (employee_group_id, employee_id)          VALUES (v_eg_id, v_emp_id);
    INSERT INTO employee_group_has_learning_path     (employee_group_id, learning_path_id)     VALUES (v_eg_id, v_lp_id);
    INSERT INTO employee_group_has_learning_material (employee_group_id, learning_material_id) VALUES (v_eg_id, v_lm_id);

    -- Sanity: confirm rows exist before the delete
    SELECT COUNT(*) INTO v_count FROM employee_group_has_employee WHERE employee_group_id = v_eg_id;
    IF v_count <> 1 THEN RAISE EXCEPTION 'TEST 11 SETUP: employee_group_has_employee expected 1 row, got %', v_count; END IF;

    DELETE FROM employee_group WHERE id = v_eg_id;

    SELECT COUNT(*) INTO v_count FROM employee_group_has_employee          WHERE employee_group_id = v_eg_id;
    IF v_count <> 0 THEN RAISE EXCEPTION 'TEST 11 FAILED: employee_group_has_employee still has % row(s)', v_count; END IF;
    SELECT COUNT(*) INTO v_count FROM employee_group_has_learning_path     WHERE employee_group_id = v_eg_id;
    IF v_count <> 0 THEN RAISE EXCEPTION 'TEST 11 FAILED: employee_group_has_learning_path still has % row(s)', v_count; END IF;
    SELECT COUNT(*) INTO v_count FROM employee_group_has_learning_material WHERE employee_group_id = v_eg_id;
    IF v_count <> 0 THEN RAISE EXCEPTION 'TEST 11 FAILED: employee_group_has_learning_material still has % row(s)', v_count; END IF;

    RAISE NOTICE 'TEST 11 PASSED: CASCADE DELETE employee_group clears all binding rows';

    -- ============================================================
    -- TEST 12: CHECK constraint — employee.age
    -- age=200 and age=-1 must both be rejected.
    -- (Inner BEGIN/EXCEPTION blocks use implicit savepoints.)
    -- ============================================================
    v_raised := FALSE;
    BEGIN
        INSERT INTO employee (fullname, age) VALUES ('Too Old', 200);
    EXCEPTION
        WHEN check_violation THEN v_raised := TRUE;
    END;
    IF NOT v_raised THEN RAISE EXCEPTION 'TEST 12 FAILED: age=200 should raise check_violation'; END IF;

    v_raised := FALSE;
    BEGIN
        INSERT INTO employee (fullname, age) VALUES ('Negative Age', -1);
    EXCEPTION
        WHEN check_violation THEN v_raised := TRUE;
    END;
    IF NOT v_raised THEN RAISE EXCEPTION 'TEST 12 FAILED: age=-1 should raise check_violation'; END IF;

    RAISE NOTICE 'TEST 12 PASSED: CHECK constraint on employee.age rejects 200 and -1';

    -- ============================================================
    -- TEST 13: CHECK constraint — learning_material.price
    -- Negative price must be rejected.
    -- ============================================================
    v_raised := FALSE;
    BEGIN
        INSERT INTO learning_material (name, type_id, price) VALUES ('Bad Price', v_lmt_id, -10);
    EXCEPTION
        WHEN check_violation THEN v_raised := TRUE;
    END;
    IF NOT v_raised THEN RAISE EXCEPTION 'TEST 13 FAILED: price=-10 should raise check_violation'; END IF;

    RAISE NOTICE 'TEST 13 PASSED: CHECK constraint on learning_material.price rejects negative values';

    -- ============================================================
    -- TEST 14: CHECK constraint — whitespace-only names
    -- ============================================================
    v_raised := FALSE;
    BEGIN
        INSERT INTO employee (fullname) VALUES ('   ');
    EXCEPTION
        WHEN check_violation THEN v_raised := TRUE;
    END;
    IF NOT v_raised THEN RAISE EXCEPTION 'TEST 14 FAILED: whitespace-only fullname should raise check_violation'; END IF;

    v_raised := FALSE;
    BEGIN
        INSERT INTO tag (name) VALUES ('   ');
    EXCEPTION
        WHEN check_violation THEN v_raised := TRUE;
    END;
    IF NOT v_raised THEN RAISE EXCEPTION 'TEST 14 FAILED: whitespace-only tag name should raise check_violation'; END IF;

    v_raised := FALSE;
    BEGIN
        INSERT INTO wiki_note (title) VALUES ('   ');
    EXCEPTION
        WHEN check_violation THEN v_raised := TRUE;
    END;
    IF NOT v_raised THEN RAISE EXCEPTION 'TEST 14 FAILED: whitespace-only wiki_note title should raise check_violation'; END IF;

    RAISE NOTICE 'TEST 14 PASSED: CHECK constraints reject whitespace-only names and titles';

    -- ============================================================
    -- TEST 15: NOT NULL violations
    -- ============================================================
    v_raised := FALSE;
    BEGIN
        INSERT INTO employee (fullname) VALUES (NULL);
    EXCEPTION
        WHEN not_null_violation THEN v_raised := TRUE;
    END;
    IF NOT v_raised THEN RAISE EXCEPTION 'TEST 15 FAILED: NULL employee.fullname should raise not_null_violation'; END IF;

    v_raised := FALSE;
    BEGIN
        INSERT INTO learning_material (name, type_id) VALUES (NULL, v_lmt_id);
    EXCEPTION
        WHEN not_null_violation THEN v_raised := TRUE;
    END;
    IF NOT v_raised THEN RAISE EXCEPTION 'TEST 15 FAILED: NULL learning_material.name should raise not_null_violation'; END IF;

    v_raised := FALSE;
    BEGIN
        INSERT INTO learning_material (name, type_id) VALUES ('No Type', NULL);
    EXCEPTION
        WHEN not_null_violation THEN v_raised := TRUE;
    END;
    IF NOT v_raised THEN RAISE EXCEPTION 'TEST 15 FAILED: NULL learning_material.type_id should raise not_null_violation'; END IF;

    RAISE NOTICE 'TEST 15 PASSED: NOT NULL constraints enforced';

    -- ============================================================
    -- TEST 16: UNIQUE constraint — duplicate tag name
    -- 'Backend' was inserted in TEST 1.
    -- ============================================================
    v_raised := FALSE;
    BEGIN
        INSERT INTO tag (name) VALUES ('Backend');
    EXCEPTION
        WHEN unique_violation THEN v_raised := TRUE;
    END;
    IF NOT v_raised THEN RAISE EXCEPTION 'TEST 16 FAILED: duplicate tag name should raise unique_violation'; END IF;

    RAISE NOTICE 'TEST 16 PASSED: UNIQUE constraint on tag.name enforced';

    -- ============================================================
    -- TEST 17: Array referential-integrity triggers and duplicate binding PK
    --
    -- 17a) tag_ids referencing a non-existent tag  → exception
    -- 17b) wiki_note_ids referencing a non-existent wiki_note → exception
    -- 17c) Inserting a duplicate composite PK into a binding table → unique_violation
    -- ============================================================

    -- 17a: non-existent tag_id
    v_raised := FALSE;
    BEGIN
        INSERT INTO learning_material (name, type_id, tag_ids)
            VALUES ('Bad Tag Ref', v_lmt_id, ARRAY[99999]);
    EXCEPTION
        WHEN OTHERS THEN v_raised := TRUE;
    END;
    IF NOT v_raised THEN RAISE EXCEPTION 'TEST 17a FAILED: tag_id=99999 should raise an exception'; END IF;

    -- 17b: non-existent wiki_note_id
    v_raised := FALSE;
    BEGIN
        INSERT INTO learning_material (name, type_id, wiki_note_ids)
            VALUES ('Bad WikiNote Ref', v_lmt_id, ARRAY[99999]);
    EXCEPTION
        WHEN OTHERS THEN v_raised := TRUE;
    END;
    IF NOT v_raised THEN RAISE EXCEPTION 'TEST 17b FAILED: wiki_note_id=99999 should raise an exception'; END IF;

    -- 17c: duplicate composite PK in a binding table
    -- v_eg_id was deleted in TEST 11; insert a fresh group, bind the employee, then try to bind again.
    INSERT INTO employee_group (groupname) VALUES ('DupTest') RETURNING id INTO v_eg_id;
    INSERT INTO employee_group_has_employee (employee_group_id, employee_id) VALUES (v_eg_id, v_emp_id);

    v_raised := FALSE;
    BEGIN
        INSERT INTO employee_group_has_employee (employee_group_id, employee_id) VALUES (v_eg_id, v_emp_id);
    EXCEPTION
        WHEN unique_violation THEN v_raised := TRUE;
    END;
    IF NOT v_raised THEN RAISE EXCEPTION 'TEST 17c FAILED: duplicate binding PK should raise unique_violation'; END IF;

    RAISE NOTICE 'TEST 17 PASSED: Array integrity triggers and duplicate binding PK enforced';

    -- ============================================================
    RAISE NOTICE '================================================================';
    RAISE NOTICE 'ALL 17 TESTS PASSED';
    RAISE NOTICE '================================================================';

END;
$$;

ROLLBACK;
