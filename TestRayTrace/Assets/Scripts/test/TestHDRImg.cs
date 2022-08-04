using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Debugger;

//https://www.youtube.com/watch?v=3Ic5ZIf74Ls

public class TestHDRImg : MonoBehaviour
{
    float PI = 3.14159f;
    public Texture2D hdrImg;
    // Start is called before the first frame update
    void Start()
    {
        Vector2 uv = new Vector2(0.5f, 0.6f);
        var dir = UVToEquirectangular(uv);
        Log.DebugVec(dir);
        uv = EquirectangularToUV(dir);
        Log.DebugVec(uv);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    bool NearZero(float x)
    {
        return Mathf.Abs(x) < 0.000001f;
    }

    //x: phi [0,2PI)
    //y: theta [0,PI]
    //z: r
    Vector3 CartesianToSpherical(Vector3 xyz)
    {
       float r = xyz.magnitude;
        xyz *= 1.0f / r;
       float phi = Mathf.Acos(xyz.z);

        if (NearZero(xyz.x) && NearZero(xyz.y))
        {
            return new Vector3(0, phi, r);
        }

        float theta = Mathf.Atan2(xyz.y, xyz.x); //Mathf.Atan2 [-PI,PI]
        //Debug.Log(phi);
        theta += (theta < 0) ? 2 * PI : 0; // only if you want [0,2pi)

        return new Vector3(theta, phi, r);
    }

   Vector3 SphericalToCartesian(float phi,float theta,float r = 1)
    {
        return new Vector3(
                r * Mathf.Sin(theta) * Mathf.Cos(phi),
                r * Mathf.Sin(theta) * Mathf.Sin(phi),
                r * Mathf.Cos(theta)
            );
    }

   Vector3 XYZ_StandardFromUnity(Vector3 p)
    {
        p.z = -p.z;
        var tmp = p.z;
        p.z = p.y;
        p.y = tmp;
        return p;
    }

   Vector3 XYZ_UnityFromStandard(Vector3 p)
    {
        var tmp = p.z;
        p.z = p.y;
        p.y = tmp;
        p.z = -p.z;
        return p;
    }

    //uv.v:down to up
   Vector2 EquirectangularToUV(Vector3 dir, bool unityDir = false)
    {
        Vector2 uv;
        dir = (dir).normalized;
        if (unityDir)
        {
            dir = XYZ_StandardFromUnity(dir);
        }
        //!!!
        //由于转球系是需要有x,y,z规定的，
        //所以要先转成标准方向
        // get theta phi from x, y comp (phi [0,2PI) theta [0,PI] )
        Debug.Log("bef " + dir.x);
       Vector3 sphereCoord = CartesianToSpherical(dir);

        uv.x = sphereCoord.x; //PI
        Debug.Log("OO " + uv.x);
        uv.x /= 2 * PI;

        uv.y = sphereCoord.y;
        uv.y /= PI;

        uv.y = 1 - uv.y;
        return uv;
    }

    //uv.v:down to up
   Vector3 UVToEquirectangular(Vector2 uv, bool unityDir = false)
    {
        uv.y = 1 - uv.y;
        uv.x *= 2 * PI;
        uv.y *= PI;
        Debug.Log(uv.x);
       Vector3 dir = SphericalToCartesian(uv.x, uv.y);
        if (unityDir)
        {
            dir = XYZ_UnityFromStandard(dir);
        }
        return dir;
    }
    
}