INSERT INTO norm.measurements (id, title) values
(0, 'Метры'),
(1, 'Квадратные метры'),
(3, 'Кубические метры'),
(4, 'Литры'),
(5, 'Килограммы'),
(6, 'Тонны') on conflict do nothing;