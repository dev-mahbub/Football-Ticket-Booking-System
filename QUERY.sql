-- DROP TABLES IF THEY ALREADY EXIST TO PREVENT CONFLICTS
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Matches;
DROP TABLE IF EXISTS Users;

-- =========================================================================
-- 1. CREATE USERS TABLE
-- =========================================================================
CREATE TABLE Users (
  user_id serial PRIMARY KEY,
  full_name varchar(100),
  email varchar(100) UNIQUE NOT NULL,
  role varchar(50) DEFAULT 'Football Fan' CHECK (role IN ('Ticket Manager', 'Football Fan')),
  phone_number varchar(50)
);

-- =========================================================================
-- 2. CREATE MATCHES TABLE
-- =========================================================================
CREATE TABLE Matches (
  match_id serial PRIMARY KEY,
  fixture varchar(100),
  tournament_category varchar(100),
  base_ticket_price int CHECK (base_ticket_price > 0),
  match_status varchar(50) DEFAULT 'Available' CHECK (
    match_status IN (
      'Available',
      'Selling Fast',
      'Sold Out',
      'Postponed'
    )
  )
);

-- =========================================================================
-- 3. CREATE BOOKINGS TABLE
-- =========================================================================
CREATE TABLE Bookings (
  booking_id serial PRIMARY KEY,
  user_id int REFERENCES users (user_id),
  match_id int REFERENCES matches (match_id),
  seat_number varchar(20),
  payment_status varchar(50) DEFAULT 'Pending' CHECK (
    payment_status IN ('Pending', 'Confirmed', 'Cancelled', 'Refunded')
  ),
  total_cost int CHECK (total_cost >= 0)
);


-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO USERS
-- =========================================================================
INSERT INTO Users (user_id, full_name, email, role, phone_number) VALUES
(1, 'Tanvir Rahman', 'tanvir@mail.com', 'Football Fan', '+8801711111111'),
(2, 'Asif Haque', 'asif@mail.com', 'Football Fan', '+8801722222222'),
(3, 'Sajjad Rahman', 'sajjad@mail.com', 'Ticket Manager', '+8801733333333'),
(4, 'Jannat Ara', 'jannat@mail.com', 'Football Fan', NULL);

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO MATCHES
-- =========================================================================
INSERT INTO Matches (match_id, fixture, tournament_category, base_ticket_price, match_status) VALUES
(101, 'Real Madrid vs Barcelona', 'Champions League', 150.00, 'Available'),
(102, 'Man City vs Liverpool', 'Premier League', 120.00, 'Selling Fast'),
(103, 'Bayern Munich vs PSG', 'Champions League', 130.00, 'Available'),
(104, 'AC Milan vs Inter Milan', 'Serie A', 90.00, 'Sold Out'),
(105, 'Juventus vs Roma', 'Serie A', 80.00, 'Available');

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO BOOKINGS
-- =========================================================================
INSERT INTO Bookings (booking_id, user_id, match_id, seat_number, payment_status, total_cost) VALUES
(501, 1, 101, 'A-12', 'Confirmed', 150.00),
(502, 1, 102, 'B-04', 'Confirmed', 120.00),
(503, 2, 101, 'A-13', 'Confirmed', 150.00),
(504, 2, 101, NULL, NULL, 150.00),
(505, 3, 102, 'C-20', 'Pending', 120.00);

-- =========================================================================
-- Query 1: Retrieve all upcoming football matches belonging to the 'Champions League' where the match status is 'Available'.
-- =========================================================================
select match_id, fixture, base_ticket_price from matches where match_status = 'Available' and tournament_category = 'Champions League'

 -- =========================================================================
  -- Query 2: Search for all users whose full names start with 'Tanvir' or contain the phrase 'Haque' (case-insensitive).
  -- =========================================================================
SELECT
  user_id,
  full_name,
  email
FROM
  users
WHERE
  full_name ILIKE 'tanvir%' or full_name ILIKE '%haque'

  -- =========================================================================
  -- Query 3: Retrieve all booking records where the payment status is missing (NULL), replacing the empty result with 'Action Required'.
  -- =========================================================================
select booking_id, user_id, match_id, coalesce(payment_status, 'Action Required') as systematic_status from bookings where payment_status is null

  -- =========================================================================
  -- Query 4: Retrieve match booking details along with the User's full name and the scheduled Match fixture teams.
  -- =========================================================================

select booking_id, full_name, fixture, total_cost from bookings 
inner join matches on bookings.match_id = matches.match_id
inner join users on bookings.user_id = users.user_id

 -- =========================================================================
  -- Query 5: Display a comprehensive list of all users and their booking IDs, ensuring that fans who have never bought a ticket are still listed.
  -- =========================================================================

select users.user_id, full_name, booking_id from users left join bookings on users.user_id = bookings.user_id

  -- =========================================================================
  -- Query 6: Find all ticket bookings where the total cost is strictly higher than the average cost of all ticket bookings.
  -- =========================================================================
select booking_id, match_id, total_cost from bookings where total_cost > (select avg(total_cost) from bookings)