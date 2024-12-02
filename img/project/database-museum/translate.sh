#!/bin/bash

sed -i -e '/<g>/,/<\/g>/d' ./schema_pl.svg 
\cp schema_pl.svg schema_en.svg 
sed -i 's/operacja/operation/g' schema_en.svg
sed -i 's/czas/audit_time/g' schema_en.svg
sed -i 's/artysta/artist/g' schema_en.svg
sed -i 's/artysta/artist/g' schema_en.svg
sed -i 's/wystawa/exhibition/g' schema_en.svg
sed -i 's/tytul/title/g' schema_en.svg
sed -i 's/typ/type/g' schema_en.svg
sed -i 's/wysokosc_cm/height_cm/g' schema_en.svg
sed -i 's/szerokosc_cm/width_cm/g' schema_en.svg
sed -i 's/waga_g/weight_g/g' schema_en.svg
sed -i 's/wartosc/value/g' schema_en.svg
sed -i 's/imie/name/g' schema_en.svg
sed -i 's/nazwisko/surname/g' schema_en.svg
sed -i 's/rok_urodzenia/birth_year/g' schema_en.svg
sed -i 's/rok_smierci/death_year/g' schema_en.svg
sed -i 's/data_od/date_from/g' schema_en.svg
sed -i 's/data_do/date_to/g' schema_en.svg 
sed -i 's/uzytkownik/museum_db_user/g' schema_en.svg
sed -i 's/haslo/password/g' schema_en.svg
sed -i 's/moderator/mod/g' schema_en.svg
sed -i 's/zdarzenie_eksponatu/event_of_exhibit/g' schema_en.svg
sed -i 's/wypozyczenie/hire/g' schema_en.svg
sed -i 's/magazynowanie/storage/g' schema_en.svg
sed -i 's/sala/room/g' schema_en.svg
sed -i 's/galeria/gallery/g' schema_en.svg
sed -i 's/nazwa/name/g' schema_en.svg
sed -i 's/eksponat/exhibit/g' schema_en.svg
sed -i 's/powierzchnia/area/g' schema_en.svg
sed -i 's/miasto/city/g' schema_en.svg
sed -i 's/powod/store_case/g' schema_en.svg
sed -i 's/magazyn/depot/g' schema_en.svg
sed -i 's/instytucja/institution/g' schema_en.svg
