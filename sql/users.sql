use VinylStore;

create user if not exists 'app'@'localhost' identified by 'app';
create user if not exists 'admin'@'localhost' identified by 'admin';
create user if not exists 'manager'@'localhost' identified by 'manager';
create user if not exists 'worker'@'localhost' identified by 'worker';

grant select on Users to 'app'@'localhost';
grant execute on procedure sample_data_generator to 'app'@'localhost';

create role if not exists worker;
create role if not exists manager;
create role if not exists admin;


grant select, insert on VinylStore.Customers to worker;
grant select, insert on  Orders to worker;
grant select on Albums_in_stores to worker;
grant select on Albums to worker;
grant select on Artists to worker;
grant select on Stores to worker;

grant execute on procedure add_customer to worker;
grant execute on procedure add_order TO worker;

grant insert on Albums to manager;
grant insert on Artists to manager;
grant select, insert, update on Albums_in_stores to manager;
grant update on Orders to manager;

grant execute on procedure add_artist to manager;
grant execute on procedure add_album to manager;
grant execute on procedure add_album_to_store to manager;
grant execute on procedure cancel_order to manager;

grant insert, delete on Users to admin;
grant execute on procedure add_user to admin;
grant execute on procedure add_store to admin;

grant worker to manager;
grant manager to admin;


grant select, insert on VinylStore.Customers to  'manager';
grant select, insert on Orders to  'manager';
grant select on Albums_in_stores to  'manager';
grant select on Albums to  'manager';
grant select on Artists to  'manager';
grant select on Stores to  'manager';

grant execute on procedure add_customer to  'manager';
grant execute on procedure add_order to  'manager';

grant all privileges on VinylStore.* to admin;

grant 'manager' to 'manager'@'localhost';
grant 'worker' to 'worker'@'localhost';
grant 'admin' to 'admin'@'localhost';

