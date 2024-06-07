-- Subscription: sub_ftcf
CREATE SUBSCRIPTION sub_ftcf
    CONNECTION 'host=old-gamma
              port=5432
              dbname=db_ftcf
              user=user_ftcf'
    PUBLICATION pub_ftcf
    WITH (
        create_slot = true,
        slot_name = 'sub_ftcf_old_alpha'
    );
    