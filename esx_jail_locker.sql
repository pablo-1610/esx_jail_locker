CREATE TABLE `lockers` (
  `identifier` varchar(80) NOT NULL,
  `name` text NOT NULL,
  `inventory` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
ALTER TABLE `lockers`
  ADD PRIMARY KEY (`identifier`);
COMMIT;