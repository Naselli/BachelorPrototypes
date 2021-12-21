using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using Shapes;

public class BezierCurves : MonoBehaviour
{
    
    public enum Type
    {
        LinearBezierCurves, QuadraticBezierCurves
    }

    public Type currentType = Type.LinearBezierCurves;
    [ Range( 0, 1 ) ] 
    public float t = 0;
    public Transform[] p;
    public Camera cam;

    private void OnDrawGizmos(){

        
        if( currentType == Type.LinearBezierCurves ){

            Draw.BlendMode = ShapesBlendMode.Opaque;
            
            Vector3[] pts = p.Select( x => x.position ).ToArray();
            for( int i = 0 ; i < pts.Length ; i++ ){
                Draw.Sphere(pts[i], .5f , Color.white);
            }
            
            Draw.Line(pts[0], pts[1], .1f, Color.white);
            Draw.Line(pts[1], pts[2], .1f, Color.white);
            Draw.Line(pts[2], pts[3], .1f, Color.white);
            
            DrawLinearBezier(pts[0], pts[1]);
            DrawLinearBezier(pts[1], pts[2]);
            DrawLinearBezier(pts[2], pts[3]);
        }

        if( currentType == Type.QuadraticBezierCurves ){
            
            Draw.BlendMode = ShapesBlendMode.Opaque;

            Vector3[] pts = p.Select( x => x.position ).ToArray();
            for( int i = 0 ; i < pts.Length ; i++ ){
                Draw.Sphere(pts[i], .5f , Color.white);
            }
            
            Vector3 a = Vector3.Lerp(pts[0], pts[1], t );
            Vector3 b = Vector3.Lerp(pts[1], pts[2], t );
            Vector3 c = Vector3.Lerp(pts[2], pts[3], t );
        
            Vector3 d = Vector3.Lerp( a , b ,t );
            Vector3 e = Vector3.Lerp( b, c, t );
        
            Vector3 f = Vector3.Lerp( d, e, t );
            
            Draw.Line(a,b, .1f, Color.green );
            Draw.Line(b,c, .1f, Color.green );
            Draw.Line(a,b, .1f, Color.green );
            Draw.Line(b,c, .1f, Color.green );
            Draw.Line(d,e, .1f, Color.green );

            Draw.Sphere( a , .3f , Color.green );
            Draw.Sphere( b , .3f , Color.green );
            Draw.Sphere( c , .3f , Color.green );
            Draw.Sphere( d , .3f , Color.green );
            Draw.Sphere( e , .3f , Color.green );

            Draw.Line(pts[0], pts[1], .1f, Color.white);
            Draw.Line(pts[2], pts[3], .1f, Color.white);
            Draw.Line(pts[1], pts[2], .1f, Color.white);
         
            DrawQuadraticBezier( pts );
            
            Draw.Sphere(f, .5f, Color.red);
        }
    }

    static Vector3 GetPoint( float t , Vector3[] pts ){
        Vector3 a = Vector3.Lerp(pts[0], pts[1], t );
        Vector3 b = Vector3.Lerp(pts[1], pts[2], t );
        Vector3 c = Vector3.Lerp(pts[2], pts[3], t );
        
        Vector3 d = Vector3.Lerp( a , b ,t );
        Vector3 e = Vector3.Lerp( b, c, t );
        
        Vector3 f = Vector3.Lerp( d, e, t );

        return f;
    }
    
    //To get the normal of the point in Quadratic Bezier curve
    static Vector3 GetTangent( float t , Vector3[] pts ){
        Vector3 a = Vector3.Lerp(pts[0], pts[1], t );
        Vector3 b = Vector3.Lerp(pts[1], pts[2], t );
        Vector3 c = Vector3.Lerp(pts[2], pts[3], t );
        Vector3 d = Vector3.Lerp( a , b ,t );
        Vector3 e = Vector3.Lerp( b, c, t );
        Vector3 f = Vector3.Lerp( d, e, t );

        Gizmos.color = new Color( 0.96f , 0.9f , 1f );
        
        return ( e - d ).normalized;

    }

    void DrawQuadraticBezier(Vector3[] pts){
        const int DETAIL = 32;
        Vector3[] drawPts = new Vector3[DETAIL];
        for( int i = 0 ; i < DETAIL ; i++ ){
            float tDraw = i / ( DETAIL - 1f );
            drawPts[ i ] = GetPoint( tDraw , pts );
        }

        Handles.color = Color.red;
        Handles.DrawAAPolyLine( drawPts );
    }

    void DrawLinearBezier(Vector3 p1, Vector3 p2){

        Vector3 pointPos = Vector3.Lerp( p1 , p2 , t );
        Draw.Sphere(pointPos, .5f, Color.green);
    }
}
