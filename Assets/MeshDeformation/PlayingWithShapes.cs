using System;
using System.Collections;
using System.Collections.Generic;
using System.Timers;
using UnityEngine;
using  Shapes;

[ExecuteAlways]
public class PlayingWithShapes : MonoBehaviour
{

    [ Range( 0 , 2 ) ] public float   lineWidth = 1;
    public                    Vector3 startPos  = new Vector3(0,3,0) ;

    private void OnEnable() => Camera.onPostRender += OnCameraPostRender;
    private void OnDisable() => Camera.onPostRender -= OnCameraPostRender;

    void OnCameraPostRender( Camera cam ){
        //called for every camera
        Draw.Thickness = lineWidth;
        //Draw.LineGeometry = LineGeometry.Flat2D;
        Draw.BlendMode = ShapesBlendMode.Additive;

        Draw.Matrix = Matrix4x4.identity;
        
        Draw.Line(  startPos + Vector3.zero , startPos + Vector3.right , Color.red );
        Draw.Line(  startPos + Vector3.zero , startPos + Vector3.up , Color.green );
        Draw.Line(  startPos + Vector3.zero , startPos + Vector3.forward , Color.blue );
    }

    private void Update(){
        
    }
}
