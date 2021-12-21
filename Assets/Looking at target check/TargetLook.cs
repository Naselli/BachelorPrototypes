using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.UIElements;

public class TargetLook : MonoBehaviour
{

    public Transform player;
    public float threshold = .99f;
    private Vector3 _leftPosVector;
    private Vector3 _rightPosVector;
    public GameObject playerObj;
    public GameObject targetObj;
    [SerializeField] private float distance;

    private void Update()
    {
        _leftPosVector = playerObj.transform.position;
        _rightPosVector = targetObj.transform.position;
        
        Vector3 vectorDiff = new Vector3(
            _leftPosVector.x - _rightPosVector.x,
            _leftPosVector.y - _rightPosVector.y,
            _leftPosVector.z - _rightPosVector.z);
                
        distance = Mathf.Sqrt(
            Mathf.Pow(vectorDiff.x, 2f) +
            Mathf.Pow(vectorDiff.y, 2f) + 
            Mathf.Pow(vectorDiff.z, 2f));
    }
    
    private void OnDrawGizmos()
    {
        var position = transform.position;
        Vector3 posTrigger = position;
        Vector3 posPlayer = player.position;
        Vector3 playerLookDir = player.forward;

        Vector3 playerToTrigger = posTrigger - posPlayer;
        Vector3 playerToTriggerDir = playerToTrigger.normalized;

        float rangeLookingTowards = Vector3.Dot(playerLookDir, playerToTriggerDir);
        bool isLooking = rangeLookingTowards >=  threshold;

        Gizmos.color = Color.cyan;
        Gizmos.DrawLine(posPlayer, posPlayer + playerLookDir);
        Gizmos.color = isLooking ? Color.green : Color.red;
        Gizmos.DrawLine(posPlayer, posPlayer+ playerToTriggerDir);  
        
        Handles.color = Color.green;
        Handles.Label(position + (Vector3.up * .8f), distance.ToString());
    }
}
