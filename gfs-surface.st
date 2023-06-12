// Precipitation
var rr3h = PAR354 // make variable from 3 hour precip

IF(FHOUR % 6 == 0)
{
     // 6 hour zone
     PAR354 = PAR354 * 2  - avgt(-3, -3, rr3h)
}
