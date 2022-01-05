using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseControl : MonoBehaviour
{
    float speed = 20.0f;
    float maxSpeed = 80.0f;
    float minSpeed = 1.0f;
    float deltaSpeed = 500; //1s

    // Start is called before the first frame update
    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
    }

    // Update is called once per frame
    void Update()
    {
        float translation = Input.GetAxis("Vertical") * speed;  //z方向
        float straffe = Input.GetAxis("Horizontal") * speed;    //x方向
        translation *= Time.deltaTime;
        straffe *= Time.deltaTime;

        transform.Translate(straffe, 0, translation);

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
    }
}
