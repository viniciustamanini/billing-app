class AddProfileConflictTrigger < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL.squish
      CREATE OR REPLACE FUNCTION check_profile_conflict()
      RETURNS trigger AS $$
      DECLARE
          new_profile_name varchar;
          conflicting_count integer;
      BEGIN
          SELECT name INTO new_profile_name FROM profile_types WHERE id = NEW.profile_type_id;
      #{'    '}
          IF new_profile_name = 'administrator' THEN
              SELECT COUNT(*) INTO conflicting_count
              FROM profiles p
              JOIN profile_types pt ON p.profile_type_id = pt.id
              WHERE p.user_id = NEW.user_id
                AND p.company_id = NEW.company_id
                AND pt.name = 'employee';
              IF conflicting_count > 0 THEN
                  RAISE EXCEPTION 'Conflict: Cannot assign administrator profile when an employee profile exists for the same user and company';
              END IF;
          ELSIF new_profile_name = 'employee' THEN
              SELECT COUNT(*) INTO conflicting_count
              FROM profiles p
              JOIN profile_types pt ON p.profile_type_id = pt.id
              WHERE p.user_id = NEW.user_id
                AND p.company_id = NEW.company_id
                AND pt.name = 'administrator';
              IF conflicting_count > 0 THEN
                  RAISE EXCEPTION 'Conflict: Cannot assign employee profile when an administrator profile exists for the same user and company';
              END IF;
          END IF;
          RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL.squish
      CREATE TRIGGER trigger_check_profile_conflict
      BEFORE INSERT OR UPDATE ON profiles
      FOR EACH ROW
      EXECUTE FUNCTION check_profile_conflict();
    SQL
  end

  def down
    execute <<-SQL.squish
      DROP TRIGGER IF EXISTS trigger_check_profile_conflict ON profiles;
      DROP FUNCTION IF EXISTS check_profile_conflict();
    SQL
  end
end
