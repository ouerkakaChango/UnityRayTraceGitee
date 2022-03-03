using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SDFUtility;
using Debugger;

public class Dao_BaseControl : MonoBehaviour
{
    float speed = 20.0f;
    float maxSpeed = 80.0f;
    float minSpeed = 1.0f;
    float deltaSpeed = 500; //1s

    SDFSphere characterShape = null;

    // Start is called before the first frame update
    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        characterShape = new SDFSphere(0.8f);
    }

    // Update is called once per frame
    void Update()
    {
        float daoScale = GetDaoScale();
        //Debug.Log(daoScale);
        float forwardMove = Input.GetAxis("Vertical") * speed * daoScale;  //«∞z
        float rightMove = Input.GetAxis("Horizontal") * speed * daoScale;  //”“x
        forwardMove *= Time.deltaTime;
        rightMove *= Time.deltaTime;

        CheckDaoCollision(ref rightMove, ref forwardMove);
        transform.Translate(rightMove, 0, forwardMove);

        //???
        float dis = (transform.position - new Vector3(0, 0.5f, 0)).magnitude;
        if (dis <= 0.5f)
        {
            //Debug.Log("In!");
        }
        else
        {
            //Debug.Log(dis);
        }

        if (Input.GetKeyDown("escape"))
        {
            Cursor.lockState = CursorLockMode.None;
        }

        float tt = Input.mouseScrollDelta.y; //1 -1
        if (Mathf.Abs(tt) > 0.00001f)
        {
            //Debug.Log(tt+" "+speed);
            if (tt > 0)
            {
                speed += Time.deltaTime * deltaSpeed;
                speed = Mathf.Min(speed, maxSpeed);
            }
            else
            {
                speed -= Time.deltaTime * deltaSpeed;
                speed = Mathf.Max(speed, minSpeed);
            }
        }

        //Debug.Log("collisionDebug: "+((transform.position - new Vector3(0, 0.5f, 0)).magnitude-characterShape.r-0.5f).ToString());
    }

    float GetDaoScale()
    {
        var daoComp = GetComponent<SDFGameSceneTrace>();
        if (daoComp == null)
        {
            return GetComponent<SDFGameTrace>().GetDaoScale();
        }
        else
        {
            return daoComp.GetDaoScale();
        }
    }

    void CheckDaoCollision(ref float rightMove, ref float forwardMove)
    {
        var collisionMgr = GetComponent<SDFGameCollisionMgr>();
        if (collisionMgr)
        {
            characterShape.r = 0.8f * GetDaoScale();
            collisionMgr.CheckMovement(characterShape, transform.position, transform.right, transform.forward, ref rightMove, ref forwardMove);
        }
    }
}
