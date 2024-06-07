-- Publication: pub_ftcf
CREATE PUBLICATION pub_ftcf
    FOR TABLE
        public.departments,
        public.regions,
        public.towns;