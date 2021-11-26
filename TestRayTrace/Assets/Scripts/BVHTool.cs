using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BVHTool : MonoBehaviour
{
    Mesh mesh;

    // Start is called before the first frame update
    void Start()
    {
        var meshFiliter = gameObject.GetComponent<MeshFilter>();
        mesh = meshFiliter.mesh;
    }

    // Update is called once per frame
    void Update()
    {
       
    }

    void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
    }
}
