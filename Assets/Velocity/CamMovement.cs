using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.Rendering;
using UnityEngine;

public class CamMovement : MonoBehaviour
{

    public Vector3 velocity;
    public Vector3 acceleration;
    
    public float lookSensetivity = 1f;
    public float accForce = 1f;
    public float dragCoefficient = .99f;
    
    private void Update(){
        
        //mouselook
        float mouseX = Input.GetAxis( "Mouse X" ) * lookSensetivity;
        float mouseY = Input.GetAxis( "Mouse Y" ) * lookSensetivity;
        
        transform.Rotate( Vector3.up, mouseX , Space.World );
        transform.Rotate( Vector3.right, -mouseY, Space.Self );

        Vector3 inputVec = Vector3.zero;
        
        void DoInputAdd(KeyCode key, Vector3 dir){
            if( Input.GetKey( key ) )
                inputVec += dir;
        }
        
        DoInputAdd(KeyCode.Z, transform.forward);
        DoInputAdd(KeyCode.S, -transform.forward);
        DoInputAdd(KeyCode.Q, -transform.right);
        DoInputAdd(KeyCode.D, transform.right);
        DoInputAdd(KeyCode.Space, Vector3.up);
        DoInputAdd(KeyCode.LeftControl, -Vector3.up);

        if( inputVec.sqrMagnitude > .001f ){
            inputVec.Normalize();
        }
        
        acceleration = inputVec * accForce; //set acceleration
        velocity += acceleration * Time.deltaTime; //calculate velocity change
        velocity *= Mathf.Pow( dragCoefficient, -Time.deltaTime ); // dampen velocity vector (not physically accurate)
        transform.position += velocity * Time.deltaTime;//move pos based on velocity
    }
}
