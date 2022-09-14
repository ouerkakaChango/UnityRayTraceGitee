using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class XCCamMouseLook : MonoBehaviour
{

    Vector2 mouseLook;
    Vector2 smoothV;
    public float sensitivity = 2.0f;
    public float smoothing = 2.0f;

    Vector3 camRight, camUp, camForward;
    Quaternion baseRot;

    void Start()
    {
        //RecordCamDir();
        RecordZeroCamDir();
    }

    void Update()
    {
        var md = new Vector2(Input.GetAxisRaw("Mouse X"), Input.GetAxisRaw("Mouse Y"));

        md = Vector2.Scale(md, new Vector2(sensitivity * smoothing, sensitivity * smoothing));
        smoothV.x = Mathf.Lerp(smoothV.x, md.x, 1f / smoothing);
        smoothV.y = Mathf.Lerp(smoothV.y, md.y, 1f / smoothing);
        mouseLook += smoothV;

        mouseLook.y = Mathf.Clamp(mouseLook.y, -90f, 90f);

        var dRotX =  Quaternion.AngleAxis(mouseLook.x, camUp);
        //用于更新transform.forward，以正确计算newRight
        transform.rotation = dRotX * baseRot;
        var newRight = Vector3.Cross(camUp, transform.forward).normalized;    
        var dRotY = Quaternion.AngleAxis(-mouseLook.y, newRight);
        transform.rotation = dRotY * dRotX * baseRot;
    }

    //###################################################
    public void RecordCamDir()
    {
        camRight = transform.right;
        camUp = transform.up;
        camForward = transform.forward;
        baseRot = transform.rotation;
    }

    public void RecordZeroCamDir()
    {
        Quaternion old = transform.rotation;
        transform.rotation = Quaternion.identity;
        camRight = transform.right;
        camUp = transform.up;
        camForward = transform.forward;
        baseRot = transform.rotation;
        transform.rotation = old;
    }
}
