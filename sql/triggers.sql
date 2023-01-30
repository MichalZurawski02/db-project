use `VinylStore`;

DELIMITER $$
drop trigger if exists remove_album_from_stores_if_0_left;
create trigger remove_album_from_stores_if_0_left
     after update
     on Albums_in_stores
     for each row
 begin
     IF (NEW.quantity = 0) THEN
         DELETE FROM Albums_in_stores WHERE quantity = 0;
     END IF;
 end;
$$
 DELIMITER ;

 DELIMITER $$
 drop trigger if exists remove_vinyl_from_store_if_order_status_is_pending;
 create trigger remove_vinyl_from_store_if_order_status_is_pending
     after insert on Orders
     for each row
     begin
         if new.status = 'pending' then
             update Albums_in_stores
             set quantity = quantity - 1
             where new.storeID = Albums_in_stores.storeID and new.albumID = Albums_in_stores.albumID;
         end if;
     end;
 $$
 DELIMITER ;

DELIMITER $$
drop trigger if exists add_vinyl_to_store_if_order_status_is_cancelled;
 create trigger add_vinyl_to_store_if_order_status_is_cancelled
     before update
     on Orders
     for each row
 begin
     declare artist_name varchar(50);
     declare artist_country varchar(50);
     declare album_name varchar(50);
     declare album_price float unsigned;
     declare album_year int unsigned;
     declare album_genre varchar(50);
     if new.status = 'cancelled' then
         select name, country
         into artist_name, artist_country
         from Artists as a
         where a.ID = (select artistID
                       from Albums as alb
                       where new.albumID = alb.ID);
         select name, price, year, genre
         into album_name, album_price, album_year, album_genre
         from Albums
         where ID = NEW.albumID;
         call add_album_to_store(artist_name, artist_country, album_name, album_price, album_year, album_genre, new.storeID, 1);

     end if;
 end;
 $$
DELIMITER ;

DELIMITER $$
drop trigger if exists remove_album_if_no_products_left;
create trigger remove_album_if_no_products_left
    after delete
    on Albums_in_stores
    for each row
begin
    if old.albumID not in (select albumID from Albums_in_stores) then
        delete from Albums where ID = old.albumID;
    end if;
end;
$$
DELIMITER ;