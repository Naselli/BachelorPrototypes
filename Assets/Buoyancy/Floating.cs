using System ;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements ;

public class Floating : MonoBehaviour {

    public Rigidbody rigidBody ;
    public float     depthBeforeSubmerged = 1f ;
    public float     displacementAmount   = 3f ;
    public int       floaterCount         = 1 ;
    public float     waterDrag            = .99f ;
    public float     waterAngularDrag     = .5f ;
    
    private void FixedUpdate ( ) {
        var   position1  = transform.position ;
        float waveHeight = WaveManager.instance.GetWaveHeight ( position1.x ) ;
        rigidBody.AddForceAtPosition(Physics.gravity, position1, ForceMode.Acceleration);
        if ( transform.position.y < waveHeight ) {
            var   position             = transform.position ;
            float displacementModifier = Mathf.Clamp01 ( (waveHeight - position.y) / depthBeforeSubmerged ) * displacementAmount ;
            rigidBody.AddForceAtPosition ( new Vector3 ( 0f , Mathf.Abs ( Physics.gravity.y ) * displacementModifier , 0f ), position , ForceMode.Acceleration ) ;
            rigidBody.AddForce(displacementModifier * -rigidBody.velocity * waterDrag *Time.fixedDeltaTime, ForceMode.VelocityChange);
            rigidBody.AddTorque(displacementModifier * -rigidBody.angularVelocity * waterAngularDrag *Time.fixedDeltaTime, ForceMode.VelocityChange);
        }
    }
}
