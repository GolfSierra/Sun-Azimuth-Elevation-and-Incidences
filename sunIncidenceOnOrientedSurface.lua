-- Sun incidence angle on a window (or any surface) with a given azimuth [0; 360°[ and elevation (vertical surface is 0°, horizontal is 90°)
-- return -1 when the sun rays cannot reach the surface of the window
-- https://fr.wikipedia.org/wiki/Panneau_solaire
local function incidence(az, el, latitude, longitude)
    local azr, elr = math.rad(az), math.rad(el)
    local az_s, el_s = getSunAzimuthElevataion(latitude, longitude, os.date('*t', os.time())) -- use os time
    local azr_s, elr_s = math.rad(az_s), math.rad(el_s)
    if el_s < 0 then return -1
    else return math.deg(math.acos(math.sin(elr_s)*math.sin(elr) + math.cos(azr_s - azr)*math.cos(elr_s)*math.cos(elr))) 
    end
end
