using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//https://toqoz.fyi/thousands-of-meshes.html

public class MeshVisualizer : MonoBehaviour
{
    Mesh mesh;
    GameObject[] spheres;
    public Mesh quadMesh;
    public Material quadMat;
    public enum VisualType
    {
        sphere,
        point,
    };
    public VisualType type = VisualType.point;
    // Start is called before the first frame update

    private ComputeBuffer meshPropertiesBuffer;
    private ComputeBuffer argsBuffer;

    private struct MeshProperties
    {
        public Matrix4x4 mat;
        public Vector4 color;

        public static int Size()
        {
            return
                sizeof(float) * 4 * 4 + // matrix;
                sizeof(float) * 4;      // color;
        }
    }

    void Start()
    {
        var meshFiliter = gameObject.GetComponent<MeshFilter>();
        mesh = meshFiliter.mesh;
        if(mesh==null)
        {
            return;
        }
        if(type== VisualType.sphere)
        {
            spheres = new GameObject[mesh.vertices.Length];
            spheres[0] = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            spheres[0].transform.localScale = new Vector3(0.05f, 0.05f, 0.05f);
            spheres[0].transform.position = this.transform.position + mesh.vertices[0];
            
            for (int i = 1; i < mesh.vertices.Length; i++)
            {
                Instantiate(spheres[0], transform.position + Vector3.Scale(mesh.vertices[i],transform.localScale), Quaternion.identity);
            }
        }
        else if(type == VisualType.point)
        {
            //BuildMatrixAndBlock();
            InitializeBuffers();
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (type == VisualType.point)
        {
            Graphics.DrawMeshInstancedIndirect(quadMesh, 0, quadMat, quadMesh.bounds, argsBuffer);
        }
    }

    void InitializeBuffers()
    {
        int n = mesh.vertices.Length;

        // Argument buffer used by DrawMeshInstancedIndirect.
        uint[] args = new uint[5] { 0, 0, 0, 0, 0 };
        // Arguments for drawing mesh.
        // 0 == number of triangle indices, 1 == population, others are only relevant if drawing submeshes.
        args[0] = (uint)quadMesh.GetIndexCount(0);
        args[1] = (uint)n;
        args[2] = (uint)quadMesh.GetIndexStart(0);
        args[3] = (uint)quadMesh.GetBaseVertex(0);
        argsBuffer = new ComputeBuffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        argsBuffer.SetData(args);

        MeshProperties[] properties = new MeshProperties[n];
        for (int i = 0; i < n; i++)
        {
            MeshProperties props = new MeshProperties();
            Vector3 position = Vector3.Scale(mesh.vertices[i],transform.lossyScale) ;
            Quaternion rotation = Quaternion.FromToRotation(new Vector3(0,0,-1), mesh.normals[i]);
            Vector3 scale = Vector3.one * 0.05f;

            props.mat = Matrix4x4.TRS(position, rotation, scale);
            props.color = Color.green;

            properties[i] = props;
        }

        meshPropertiesBuffer = new ComputeBuffer(n, MeshProperties.Size());
        meshPropertiesBuffer.SetData(properties);
        quadMat.SetBuffer("_Properties", meshPropertiesBuffer);
    }

    private void OnDisable()
    {
        // Release gracefully.
        if (meshPropertiesBuffer != null)
        {
            meshPropertiesBuffer.Release();
        }
        meshPropertiesBuffer = null;

        if (argsBuffer != null)
        {
            argsBuffer.Release();
        }
        argsBuffer = null;
    }
}
