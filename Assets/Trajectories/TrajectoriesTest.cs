using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[ExecuteAlways]
public class TrajectoriesTest : MonoBehaviour
{

    public Camera cam;
    [Range(0f,8f)]
    public float launchSpeed;
    //[Range(0f, 90f)]
    //public float launchAngle;

    private Vector3 mouseGroundPos;
    
    //public float LaunchAngRad => launchAngle * Mathf.Deg2Rad;

    private void Update(){
        mouseGroundPos = GetCursorGroundPosition();
    }

    private void OnDrawGizmos(){

        Vector3 dirPlayerToTarget = ( mouseGroundPos - transform.position ).normalized;
        float distToTraget = Vector3.Distance( transform.position , mouseGroundPos );
        (float angleLow, float angleHigh) launchAngles = GetLaunchAngle( distToTraget , launchSpeed );
        
        
        Shapes.Draw.Color = Color.white;
        const int pointCount = 32;
        const float dt = 1f / 10f;
        for( int i = 0 ; i < pointCount ; i++ ){
            
            float time = i * dt;
            Vector2 pt2DA = GetPointInTrajectory( transform.position , launchSpeed , launchAngles.angleLow , time );
            Vector2 pt2DB = GetPointInTrajectory( transform.position , launchSpeed , launchAngles.angleHigh , time );

            void TryDrawTrajectoryPoint( Vector2 point2D ){
                if( point2D.y < 0 ) return;
                Vector3 pt = dirPlayerToTarget * point2D.x; //lateral offset
                pt.y = point2D.y; //vertical offset
                Shapes.Draw.Sphere( pt, .1f );
            }
            
            TryDrawTrajectoryPoint( pt2DA );
            TryDrawTrajectoryPoint( pt2DB );
        }
        
        Shapes.Draw.Color = Color.red;
        Shapes.Draw.Sphere(mouseGroundPos, .1f);
    }

    static Vector2 GetPointInTrajectory(Vector2 startPoint, float launchSpeed , float launchAngRad , float time ){
         
        float gravity = Physics.gravity.y;

        float xDisp = launchSpeed * time * Mathf.Cos( launchAngRad );
        float yDisp = launchSpeed * time * Mathf.Sin( launchAngRad ) + .5f * gravity * time * time;

        return startPoint + new Vector2( xDisp , yDisp );
    }

    Vector3 GetCursorGroundPosition(){
        
        Ray ray = cam.ScreenPointToRay( Input.mousePosition );
        Plane groundPlane = new Plane(Vector3.up,  Vector3.zero );
        
        if( groundPlane.Raycast( ray, out float hitDist ) ){
            Vector3 groundPos = ray.GetPoint( hitDist );
            groundPos.y = 0f;
            return groundPos;
        }
        return default;
    }

        //d = s*s*sin(2*angle) / g                      
        //d * g = s*s*sin(2*angle)                  
        //(d * g) / (s*s) = sin(2*angle)            
        //asin( (d * g) / (s*s) ) = 2*angle         
        //(asin( (d * g) / (s*s) ) ) / 2 = angle    
        //angle = (asin( (d * g) / (s*s) ) ) / 2  
    static (float,float) GetLaunchAngle( float dist, float speed){
        float gravity = Physics.gravity.y;
        float asinContent = Mathf.Clamp( ( dist * -gravity ) / ( speed * speed ), -1,  1);
        return 
            ( Mathf.Asin( asinContent ) / 2 , 
                (Mathf.Asin( -asinContent )  + Mathf.PI) / 2 );
    }
}
