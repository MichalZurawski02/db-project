use
    `VinylStore`;
DELIMITER
$$
drop procedure if exists sample_data_generator;
create procedure sample_data_generator()
begin
    insert into Artists (name, country)
    values ('David Bowie', 'UK'),
           ('The Beatles', 'UK'),
           ('Radiohead', 'UK'),
           ('Kendrick Lamar', 'USA'),
           ('Pink Floyd', 'UK'),
           ('The Velvet Underground', 'USA'),
           ('The Cure', 'UK'),
           ('Slint', 'USA'),
           ('Joy Division', 'UK'),
           ('The Doors', 'UK'),
           ('Tame Impala', 'Australia'),
           ('Aphex Twin', 'Ireland'),
           ('Kraftwerk', 'Germany'),
           ('Кино [Kino]', 'Russia'),
           ('La Femme', 'France'),
           ('Bjork', 'Iceland'),
           ('Republika', 'Poland'),
           ('Pauli Exclusion', 'Poland');
    insert into Albums (artistID, name, price, year, genre)
    values (1, 'Heroes', 549.00, 1970, 'Art Rock'),
           (2, 'Magical Mystery Tour', 249.90, 1967, 'Psychedelic Pop'),
           (3, 'OK Computer', 150.20, 1997, 'Alternative Rock'),
           (4, 'To Pimp a Butterfly ', 250.50, 2015, 'Conscious Hip Hop'),
           (5, 'Meddle', 431.49, 1971, 'Progressive Rock'),
           (6, 'White Light / White Heat', 120.00, 1968, 'Experimental Rock'),
           (7, 'Disintegration', 104.30, 1989, 'Post-Punk'),
           (8, 'Spiderland', 152.00, 1991, 'Math Rock'),
           (9, 'Unknown Pleasures', 1289.99, 1979, 'Post-Punk'),
           (10, 'The Doors', 344.00, 1967, 'Psychedelic Rock'),
           (11, 'Currents', 147.90, 2015, 'Dream Pop'),
           (12, 'Selected Ambient Works 85-92', 522.00, 1992, 'Ambient'),
           (13, 'Computerwelt ', 110.00, 1981, 'Krautrock'),
           (14, 'Звезда по имени Солнце ', 413.00, 1989, 'New Wave'),
           (15, 'Paradigmes ', 105.90, 2021, 'Neo-Psychedelia'),
           (16, 'Debut ', 123.00, 1993, 'Art Pop'),
           (17, '1984 ', 124.00, 1984, 'Post-Punk'),
           (18, 'Unknown', 413.00, 2023, 'Art Rock');
    insert into Stores (city, street, number, zip_code, phone_number)
    values ('Wrocław', 'Legnicka', '55F', '54203', 345223234),
           ('Jelenia Gora', 'Wolnosci', '54', '58500', 574934057),
           ('Krosnice', 'Parkowa', '17', '56320', 206535723),
           ('Krakow', 'Szewska', '4', '30109', 226941426);

end;
$$
DELIMITER ;


DELIMITER
$$
drop procedure if exists add_customer;
create procedure add_customer(IN n varchar(50), ln varchar(50), pn int, em varchar(50), out c_id int)
begin
    insert ignore into Customers (name, lastname, phone_number, email) value (n, ln, pn, em);
    select ID into c_id from Customers where (name, lastname, phone_number, email) = (n, ln, pn, em);
end;
$$
DELIMITER ;


DELIMITER
$$
drop procedure if exists add_artist;
create procedure add_artist(IN n varchar(50), c varchar(50), out a_id int)
begin
    insert ignore into Artists (name, country) value (n, c);
    select ID into a_id from Artists where (name, country) = (n, c);
end;
$$
DELIMITER ;


DELIMITER
$$
drop procedure if exists add_user;
create procedure add_user(IN log varchar(50), pas varchar(100), t enum ('worker', 'manager', 'admin'), n varchar(50),
                          ln varchar(50), g enum ('K', 'M'), out u_id int)
begin
    insert into Users (login, password, type, name, lastname, gender) value (log, pas, t, n, ln, g);
    select ID into u_id from Users where (login, password, type, name, lastname, gender) = (log, pas, t, n, ln, g);
end;
$$
DELIMITER ;


DELIMITER
$$
drop procedure if exists add_store;
create procedure add_store(IN c varchar(50), s varchar(50), n varchar(4), zc varchar(5), p int unsigned, out s_id int)
begin
    insert into Stores (city, street, number, zip_code, phone_number)
    values (c, s, n, zc, p);
    select ID into s_id from Stores where (city, street, number, zip_code, phone_number) = (c, s, n, zc, p);
end;
$$
DELIMITER ;


DELIMITER $$
drop procedure if exists add_album;
create procedure add_album(IN artist_name varchar(50), artist_country varchar(50), album_name varchar(50),
                               album_price float, album_year int, album_genre varchar(50), out ar_ID int, out al_ID int)
begin
    start transaction ;
    if exists(select name from Albums where name = album_name) then
        select ID, artistID into al_ID, ar_ID from Albums where name = album_name;
    else
        call add_artist(artist_name, artist_country, @arID);
        SELECT @arID into ar_ID;
        insert ignore into Albums (artistID, name, price, year, genre)
            value (@arID, album_name, album_price, album_year, album_genre);
        select ID
        into al_ID
        from Albums
        where (artistID, name, price, year, genre) = (@arID, album_name, album_price, album_year, album_genre);
        commit;
    end if;
end;
$$
DELIMITER ;

DELIMITER
$$
drop procedure if exists add_order;
create procedure add_order(IN c_name varchar(50), c_lastname varchar(50),
                           c_phone int unsigned, c_email varchar(50),
                           alID int unsigned, sID int unsigned, uID int unsigned, d date)
begin
    declare albumAmount int;
    start transaction;
    set albumAmount = (select quantity from Albums_in_stores where (albumID, storeID) = (alID, sID));
    if albumAmount > 0 then
        call add_customer(c_name, c_lastname, c_phone, c_email, @clID);
        insert into Orders (customerID, albumID, storeID, userID, date, status)
            value (@clID, alID, sID, uID, d, 'pending');

        update Albums_in_stores set quantity = quantity - 1 where (albumID, storeID) = (alID, sID);
    else
        rollback;
    end if;
    commit;
end;
$$
DELIMITER ;


DELIMITER $$
drop procedure if exists add_album_to_store;
create procedure add_album_to_store(IN artist_name varchar(50), artist_country varchar(50),
                                  album_name varchar(50), album_price float unsigned, album_year int unsigned , album_genre varchar(50),
                                  store_ID int unsigned, qty int unsigned)
begin
    start transaction;
    if exists(select ID from Stores where ID = store_ID) then
        call add_album(artist_name, artist_country, album_name, album_price, album_year, album_genre, @arID, @alID);
        select @arID, @alID; # Tutaj model_ID = null
        if exists(select albumID, storeID
                  from Albums_in_stores
                  where (albumID, storeID) = (@alID, store_ID)) then
            update Albums_in_stores
            set quantity = quantity + qty
            where (albumID, storeID) = (@alID, store_ID);
        else
            insert into Albums_in_stores (albumID, storeID, quantity) value (@alID, store_ID, qty);
        end if;

    else
        rollback;
    end if;
    commit;
end;
$$
DELIMITER ;


DELIMITER $$
drop procedure if exists cancel_order;
create procedure cancel_order(o_id int)
begin
    declare s enum ('pending', 'done','cancelled');
    declare ar_name varchar(50);
    declare ar_country varchar(50);
    declare al_id int unsigned;
    declare s_id int unsigned;
    declare yr int unsigned;
    declare gen varchar(50);
    declare al_name varchar(50);
    declare ar_id int unsigned;
    declare al_price float;
    select albumID, storeID into al_id, s_id from Orders where ID = o_id;
    select year, genre, name, price into yr, gen, al_name, al_price from Albums where ID = al_id;
    select status into s from Orders where ID = o_id;
    select artistID into ar_id from Albums where ID = al_id;
    select name, country into ar_name, ar_country from Artists where ID = ar_id;
    if s = 'pending' then
        update Orders
        set status = 'cancelled'
        where (ID = o_id);
        call add_album_to_store(ar_name, ar_country, al_name, al_price, yr, gen, s_id, 1);
    end if;
end;
$$
DELIMITER ;