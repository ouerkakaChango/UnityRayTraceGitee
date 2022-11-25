using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BoxGizmo : MonoBehaviour
{
    public Color wireColor = Color.black;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = wireColor;
        Gizmos.DrawWireCube(transform.position, transform.lossyScale);
    }
}
