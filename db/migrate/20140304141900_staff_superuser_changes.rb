class StaffSuperuserChanges < ActiveRecord::Migration

  include ClassLogger

  def up
    logger.warn "Demoting superusers who aren't part of CalCentral Dev or Ops teams"
    User::Auth.update_all(
      "is_viewer = true, is_superuser = false",
      "is_superuser = true AND uid NOT IN ( #{staff_uids} )"
    )

    logger.warn "Adding Paul Farestveit as superuser"
    User::Auth.new_or_update_superuser!(paul)
  end

  def down
    logger.warn "StaffSuperuserChanges is a non-reversible migration"
  end

  private

  def staff_uids
    "'323487', '238382', '208861', '675750', '322279', '2040', '904715', '211159', '978966', '1044957', '1051203', '53791', '12492', '1049291'"
  end

  def paul
    '1049291'
  end
end
