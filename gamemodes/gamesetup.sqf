
//create direction arrows and hide both boxes and arrows

if (inorder) then
{
  {
  _marker =  createmarker [_x + "1",getMarkerPos _x,0];
  _marker setMarkerType "mil_arrow";
  _marker setMarkerDir markerdir _x;
  _marker setMarkerSize [1.5,1.5];
  _marker setMarkerAlpha 0;
  _x setMarkerAlpha 0;
  _marker setMarkerColor "ColorRed";

  }foreach checkpoints;
}
else {
  {
  _marker =  createmarker [_x + "1",getMarkerPos _x,0];
  _marker setMarkerType "mil_circle";
  //_marker setMarkerSize [1.5,1.5];
  _marker setMarkerAlpha 0;
  _x setMarkerAlpha 0;
  _marker setMarkerColor "ColorRed";

  }foreach checkpoints;
};
gameready = true ;
