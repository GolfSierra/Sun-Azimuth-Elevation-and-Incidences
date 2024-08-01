-- https://www.sciencedirect.com/science/article/pii/S0960148121004031?ref=cra_js_challenge&fr=RR-1
-- https://fr.wikipedia.org/wiki/Position_du_Soleil
-- Errors of the right ascension and declination of the Sun < 1/60°
-- Error of the equation of time < 3.5 s, if the input year is between 1950 and 2050.
-- xlat° > in northen hemisphere & xlon°>0 for east longitude

local function getSunAzimuthElevation(xlat, xlon, time)
    
    local rpd = math.pi/180 -- all in degrees
    
    -- time to utc
    time = time or os.time()
    if type(time) == 'table' then time = os.time(time) end
    local date = os.date('*t', time)
    local timezone = (os.time(date) - os.time(os.date('!*t', time))) / 3600
    if date.isdst then timezone = timezone + 1 end
    local utcdate = os.date('*t', time - timezone * 3600)
    local gmtime = (utcdate.hour + utcdate.min/60 + utcdate.sec/3600) -- decimal hour
    
    -- reference is 1/1/2000
    local dyear = utcdate.year-2000
    local xleap = math.floor(dyear/4)
    if dyear > 0 and dyear % 4 ~= 0 then xleap = xleap + 1 end
    
    -- astronomical almanach
    local n = -1.5 + dyear*365.0 + xleap + utcdate.yday + gmtime/24                 -- number of days of Terrestrial Time (TT) from J2000.0 UT
    local L = (280.460 + 0.9856474*n) % 360.0                                       -- mean longitude of the Sun corrected for aberration
    local g = (357.528 + 0.9856003*n) % 360.0                                       -- mean anomaly
    local lambda = (L + 1.915*math.sin(g*rpd) + 0.020*math.sin(2*g*rpd)) % 360.0    -- ecliptic longitude
    local epsilon = 23.439 - 0.0000004*n                                            -- obliquity of ecliptic
    local alpha = (math.atan(math.cos(epsilon*rpd)*math.sin(lambda*rpd), math.cos(lambda*rpd)) / rpd) % 360.0 -- alpha & lambda in the same quadrant (atan2) - right ascension
    local delta = math.asin(math.sin(epsilon*rpd)*math.sin(lambda*rpd)) / rpd       -- declination of the Sun
    local R = 1.00014 - 0.01671*math.cos(g*rpd) - 0.00014*math.cos(2*g*rpd)         -- Earth-Sun distance
    local EoT = ((L - alpha) + 180.0) % 360 - 180.0                                 -- Equation of Time
    
    -- solar geometry
    local sunlat = delta
    local sunlon = -15.0*(gmtime - 12.0 + EoT*4/60)
    local PHIo = xlat*rpd
    local PHIs = sunlat*rpd
    local LAMo = xlon*rpd
    local LAMs = sunlon*rpd
    local Sx = math.cos(PHIs)*math.sin(LAMs-LAMo) -- S vector ointing from the observer to the center of the Sun
    local s  = math.cos(PHIs)*math.cos(LAMs-LAMo)
    local Sy = math.cos(PHIo)*math.sin(PHIs) - math.sin(PHIo)*s
    local Sz = math.sin(PHIo)*math.sin(PHIs) + math.cos(PHIo)*s  -- Sx^2+Sy^2+Sz^2 = 1
    local azimuth = math.atan(-Sx, -Sy)/rpd + 180 --0 to 360°
    local elevation = 90 - math.acos(Sz)/rpd -- -180 to 180°
    
    return azimuth, elevation
    
end
