drop database if exists `VinylStore`;
create database `VinylStore`;
use `VinylStore`;

create table Users
(
    ID       int unsigned auto_increment primary key,
    login    varchar(50)  not null unique,
    password varchar(100) not null,
    type     enum ('worker', 'manager', 'admin'),
    name     varchar(50)  not null,
    lastname varchar(50)  not null,
    gender   enum ('M', 'K')
);
create table Customers
(
    ID           int unsigned auto_increment primary key,
    name         varchar(50)  not null,
    lastname     varchar(50)  not null,
    phone_number int unsigned not null,
    email        varchar(50),
    check ( phone_number >= 100000000 and phone_number <= 999999999)
);

create table Artists
(
    ID      int unsigned auto_increment primary key,
    name    varchar(50) not null unique,
    country varchar(50) not null
);
create table Albums
(
    ID        int unsigned auto_increment primary key,
    artistID  int unsigned not null,
    name      varchar(50) not null unique,
    price     float unsigned,
    year      int unsigned,
    genre     varchar(50),
    foreign key (artistID) references Artists (ID),
    check ( year > 1900 ),
    check ( price > 0 )
);

create table Stores
(
    ID           int unsigned auto_increment,
    city         varchar(50) not null,
    street       varchar(50) not null,
    number       varchar(4)  not null,
    zip_code     char(5)     not null,
    phone_number int unsigned,
    primary key (ID),
    check ( phone_number >= 100000000 and phone_number <= 999999999 )
);

create table Albums_in_stores
(
    albumID  int unsigned,
    storeID  int unsigned,
    quantity int unsigned,
    primary key (albumID, storeID),
    foreign key (albumID) references Albums (ID),
    foreign key (storeID) references Stores (ID),
    check ( quantity >= 0 )
);

create table Orders
(
    ID         int unsigned auto_increment primary key,
    customerID int unsigned not null,
    albumID    int unsigned not null,
    storeID    int unsigned not null,
    userID     int unsigned not null,
    date       date        not null,
    status     enum ('pending', 'done', 'cancelled'),
    foreign key (customerID) references Customers (ID),
    foreign key (albumID) references Albums (ID),
    foreign key (storeID) references Stores (ID),
    foreign key (userID) references Users (ID)
);
