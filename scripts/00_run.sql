-- =============================================================================
-- SCRIPT RUN - Initialisation complete de la base de donnees
-- =============================================================================
-- Ce script execute dans l'ordre :
-- 1. Creation des tables et insertion des donnees
-- 2. Creation des procedures et fonctions PL/SQL
-- 3. Creation des declencheurs (triggers)
-- =============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT =========================================
PROMPT INITIALISATION COMPLETE DE LA BASE
PROMPT =========================================
PROMPT

PROMPT [ETAPE 1/3] Creation des tables et insertion des donnees...
@@init_all.sql

PROMPT
PROMPT [ETAPE 2/3] Creation des procedures et fonctions...
@@05_procedures_fonctions.sql

PROMPT
PROMPT [ETAPE 3/3] Creation des declencheurs (triggers)...
@@06_triggers.sql

PROMPT
PROMPT =========================================
PROMPT INITIALISATION TERMINEE AVEC SUCCES
PROMPT =========================================
PROMPT
PROMPT Vous pouvez maintenant executer les tests avec :
PROMPT   @07_tests.sql
PROMPT =========================================
