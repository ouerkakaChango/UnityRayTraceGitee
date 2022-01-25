using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshDebugger : MonoBehaviour
{
    public MeshFilter meshFilter;
    // Start is called before the first frame update
    void Start()
    {
        var mesh = meshFilter.mesh;
        Debug.Log("vertices: " + mesh.vertices.Length);
        Debug.Log("tris: " + mesh.triangles.Length);
        Debug.Log("uv: " + mesh.uv.Length);
        Debug.Log("subMeshs: " + mesh.subMeshCount);
        //mesh.GetSubMesh(0);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
