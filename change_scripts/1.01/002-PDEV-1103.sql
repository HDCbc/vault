/*
    Author: Jonathan Zacharuk
    Date:   March 11, 2020
    Story:  PDEV-1103: Make Practitioner Identifier and Type Nullable
*/

alter table universal.practitioner alter column identifier drop not null;
alter table universal.practitioner alter column identifier_type drop not null;
