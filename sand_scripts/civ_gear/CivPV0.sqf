if (!isServer) exitwith {};
_marker=_this select 0;
_veh = "C_Hatchback_01_F" createVehicle getMarkerPos _marker;
_veh = setvehiclelock  "LOCKED";