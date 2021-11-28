using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NormalVisualizer : MonoBehaviour
{
    public enum VisualType
    {
        mesh,
        data,
    };

    public VisualType type = VisualType.mesh;
    public Material mat;

    //type mesh
    Mesh mesh;

    //type data
    public List<Vector3> vertices;
    public List<Vector3> normals;

    // Start is called before the first frame update
    void Start()
    {
        if (type == VisualType.mesh)
        {
            var meshFilter = gameObject.GetComponent<MeshFilter>();
            mesh = meshFilter.mesh;
        }
        else if (type == VisualType.data)
        {
           

        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnRenderObject()
    {
        if (type == VisualType.mesh)
        {
            RenderMeshNormal();
        }
        else if(type == VisualType.data)
        {
            RenderDataNormal();
        }
    }

    void RenderMeshNormal()
    {
        mat.SetPass(0);
        GL.Color(new Color(1, 1, 0, 0.8F));
        GL.PushMatrix();
        GL.Begin(GL.LINES);
        for (int i = 0; i < mesh.vertices.Length; i++)
        {
            var p1 = mesh.vertices[i];
            var m2world = gameObject.transform.localToWorldMatrix;
            p1 =  m2world.MultiplyPoint(p1);
            var p2 = p1 + 1 * mesh.normals[i];
            GL.Vertex(p1);
            GL.Vertex(p2);
        }
        GL.End();
        GL.PopMatrix();
    }

    void RenderDataNormal()
    {
        mat.SetPass(0);
        GL.Color(new Color(1, 1, 0, 0.8F));
        GL.PushMatrix();
        GL.Begin(GL.LINES);
        for (int i = 0; i < vertices.Count; i++)
        {
            var p1 = vertices[i];
            var p2 = p1 + 1 * normals[i];
            GL.Vertex(p1);
            GL.Vertex(p2);
        }
        GL.End();
        GL.PopMatrix();
    }

    public void AddData(in Vector3[] vertices_, in Vector3[] normals_)
    {
        if(vertices == null)
        {
            vertices = new List<Vector3>();
        }
        if(normals == null)
        {
            normals = new List<Vector3>();
        }
        vertices.AddRange(vertices_);
        normals.AddRange(normals_);
    }
}
