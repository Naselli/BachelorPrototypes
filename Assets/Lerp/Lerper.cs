using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;


[ExecuteAlways] 
public class Lerper : MonoBehaviour {
    
    public enum Type {
        Lerp, InverseL, Remap
    }

    public Type currentType = Type.Lerp;
    public Transform a;
    public Transform b;

    [Range(0, 1)] public float t = 0;

    private void Update(){
        //Blend position values
        Vector3 aPos = a.position;
        Vector3 bPos = b.position;
        transform.position = Vector3.Lerp( aPos, bPos, t );
        
        //Blend rotation values
        Quaternion aRot = a.rotation;
        Quaternion bRot = b.rotation;
        transform.rotation = Quaternion.Slerp( aRot , bRot , t );
    }

    // value = ( (1-t)a+tb)    // lerp
    // value = a+t(b-a)        // also lerp
    // value-a = t(b-a)         
    // (value-a)/(b-a) = t     // inverse lerp

    static float Lerp( float a , float b , float t ) => ( 1 - t ) * a + b * t;
    static float InverseLerp( float a , float b , float v ) => ( v - a ) / ( b - a );

    static float Remap( float iMin , float iMax , float oMin , float oMax , float v ){
        float f = InverseLerp( iMin , iMax , v );
        return Lerp( oMin , oMax , f );
    }
    // use case of inverse lerp
    // Audio volume by distance
    // if player is 10m away, volume is 1
    // if player is 20m away, volume is 0

    private void OnDrawGizmos(){
        Gizmos.DrawLine( a.position, b.position );
    }
}
