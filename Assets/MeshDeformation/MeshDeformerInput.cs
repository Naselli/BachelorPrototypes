using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshDeformerInput : MonoBehaviour {
    public float      force       = 10f ;
    public float      forceOffset = .1f ;
    public GameObject player ; 
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        HandleInput();
    }

    void HandleInput ( ) {
        //if ( player == null  && Input.GetMouseButton(0)) {
        //    Ray        inputRay = Camera.main.ScreenPointToRay ( Input.mousePosition ) ;
        //    RaycastHit hit ;
        //    if ( Physics.Raycast(inputRay, out hit) ) {
        //        MeshDeformer deformer = hit.collider.GetComponent < MeshDeformer > ( ) ;
        //        if ( deformer ) {
        //            Vector3 point = hit.point ;
        //            point += hit.normal * forceOffset ;
        //            deformer.AddDeformingForce ( point , force ) ;
        //        }
        //    }
        //}
        //else {
            Ray        inputRay = new Ray(transform.position, Vector3.down);
            RaycastHit hit ;
            if ( Physics.Raycast(inputRay, out hit) ) {
                MeshDeformer deformer = hit.collider.GetComponent < MeshDeformer > ( ) ;
                if ( deformer ) {
                    Vector3 point = hit.point ;
                    point += hit.normal * forceOffset ;
                    deformer.AddDeformingForce ( point , force ) ;
                }
            }
        //}
       
    }

}
