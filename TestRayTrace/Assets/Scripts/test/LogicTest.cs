using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LogicTest : MonoBehaviour
{
    int[] n = new int[10];
    bool finish = false;
    // Start is called before the first frame update
    void Start()
    {
        Solve();
        //GiveAns();
        //Debug.Log(Check(true));
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void Solve()
    {
        finish = false;
        Give(0);
    }

    void Give(int inx)
    {
        if(inx == 10)
        {
            if(Check())
            {
                PrintAns();
            }
            return;
        }
        for(int i=0;i<4;i++)
        {
            n[inx] = i;
            if(finish)
            {
                break;
            }
            Give(inx + 1);
        }
    }

    void PrintAns()
    {
        string re = "";
        for(int i=0;i<n.Length;i++)
        {
            re += n[i] + " ";
        }
        Debug.Log(re);
    }

    bool Check(bool blog = false)
    {
        //1.
        //2.
        int ans2 = n[1];
        int ans5 = ans2 == 0? 2 : (ans2 == 1? 3:(ans2 == 2 ? 0 : 1));
        if(ans5 != n[4])
        {
            if(blog)
            {
                Debug.Log("error 2");
            }
            return false;
        }
        //3. 2 3 4 6  3B+A
        int count = 0;
        bool c1 = n[1] != n[2] && n[2] == n[3] && n[3] == n[5];
        count += c1?1:0;
        c1 = n[2] != n[1] && n[1] == n[3] && n[3] == n[5];
        count += c1 ? 1 : 0;
        c1 = n[3] != n[1] && n[1] == n[2] && n[2] == n[5];
        count += c1 ? 1 : 0;
        c1 = n[5] != n[1] && n[1] == n[2] && n[2] == n[3];
        count += c1 ? 1 : 0;
        if(count>1)
        {
            Debug.LogError("Fuck 3");
        }
        if(count==0)
        {
            if (blog)
            {
                Debug.Log("error 3");
            }
            return false;
        }

        //4. 15 27 19 610
        count = 0;
        c1 = n[0] == n[4];
        count += c1 ? 1 : 0;

        c1 = n[1] == n[6];
        count += c1 ? 1 : 0;

        c1 = n[0] == n[8];
        count += c1 ? 1 : 0;
   
        c1 = n[5] == n[9];
        count += c1 ? 1 : 0;
        if (count > 1)
        {
            return false;
            //Debug.LogError("Fuck 4");
        }
        if (count == 0)
        {
            if (blog)
            {
                Debug.Log("error 4");
            }
            return false;
        }

        //5. 58 54 59 57
        count = 0;
        c1 = n[4] == n[7];
        count += c1 ? 1 : 0;
        c1 = n[4] == n[3];
        count += c1 ? 1 : 0;
        c1 = n[4] == n[8];
        count += c1 ? 1 : 0;
        c1 = n[4] == n[6];
        count += c1 ? 1 : 0;
        if (count > 1)
        {
            return false;
            //Debug.LogError("Fuck 5");
        }
        if (count == 0)
        {
            if (blog)
            {
                Debug.Log("error 5");
            }
            return false;
        }

        //6. 248 168 3108 598
        count = 0;
        c1 = n[1] == n[3] && n[1] == n[7];
        count += c1 ? 1 : 0;
        c1 = n[0] == n[5] && n[5] == n[7];
        count += c1 ? 1 : 0;
        c1 = n[2] == n[9] && n[9] == n[7];
        count += c1 ? 1 : 0;
        c1 = n[4] == n[8] && n[8] == n[7];
        count += c1 ? 1 : 0;
        if (count > 1)
        {
            return false;
            //Debug.LogError("Fuck 6");
        }
        if (count == 0)
        {
            if (blog)
            {
                Debug.Log("error 6");
            }
            return false;
        }

        //7.
        int min = GetMinD();
        if(n[6] == 0 && min!=2)
        {
            if (blog)
            {
                Debug.Log("error 7.1");
            }
            return false;
        }
        if (n[6] == 1 && min != 1)
        {
            if (blog)
            {
                Debug.Log("error 7.2");
            }
            return false;
        }
        if (n[6] == 2 && min != 0)
        {
            if (blog)
            {
                Debug.Log("error 7.3");
            }
            return false;
        }
        if (n[6] == 3 && min != 3)
        {
            if (blog)
            {
                Debug.Log("error 7.4");
            }
            return false;
        }

        //8.
        count = 0;
        c1 = CheckNotNeighbour(n[0], n[6]);
        if (c1 && n[7]!=0)
        {
            if (blog)
            {
                Debug.Log("error 8.1");
            }
            return false;
        }
        else if(c1 && n[7] == 0)
        {
            count++;
        }

        c1 = CheckNotNeighbour(n[0], n[4]);
        if ( c1 && n[7] != 1)
        {
            if (blog)
            {
                Debug.Log("error 8.2");
            }
            return false;
        }
        else if(c1 && n[7] == 1)
        {
            count++;
        }

        c1 = CheckNotNeighbour(n[0], n[1]);
        if ( c1&& n[7] != 2)
        {
            if (blog)
            {
                Debug.Log("error 8.3");
            }
            return false;
        }
        else if(c1 && n[7] == 2)
        {
            count++;
        }

        c1 = CheckNotNeighbour(n[0], n[9]);
        if ( c1 && n[7] != 3)
        {
            if (blog)
            {
                Debug.Log("error 8.4");
            }
            return false;
        }
        else if (c1 && n[7] == 3)
        {
            count++;
        }

        if (count!=1)
        {
            return false;
        }

        //9.
        bool condi91 = n[0] == n[5];
        bool cindi92 = n[map9()] == n[4];

        if(condi91 == cindi92)
        {
            if (blog)
            {
                Debug.Log("error 9");
            }
            return false;
        }

        //10.
        if(GetDif()!=map10())
        {
            if (blog)
            {
                Debug.Log("error 10");
            }
            return false;
        }

        return true;
    }

    int GetMinD()
    {
        int[] sum = new int[4];
        for(int i=0;i<10;i++)
        {
            sum[n[i]]++;
        }
        int min = sum[0];
        int minInx = 0;
        for(int i=1;i<4;i++)
        {
            if(sum[i]<min)
            {
                min = sum[i];
                minInx = i;
            }
        }
        return minInx;
    }

    bool CheckNotNeighbour(int a,int b)
    {
        return Mathf.Abs(a - b) > 1;
    }

    int map9()
    {
        int ans9 = n[8];
        return ans9 == 0 ? 5 : (ans9 == 1 ? 9 : (ans9 == 2 ? 1 : 8));
    }

    int map10()
    {
        int ans10 = n[9];
        return ans10 == 0 ? 3 : (ans10 == 1 ? 2 : (ans10 == 2 ? 4 : 1));
    }

    int GetDif()
    {
        int[] sum = new int[4];
        for (int i = 0; i < 10; i++)
        {
            sum[n[i]]++;
        }
        int min = sum[0];
        int max = sum[0];
        for (int i = 1; i < 4; i++)
        {
            if (sum[i] < min)
            {
                min = sum[i];
            }

            if (sum[i] > max)
            {
                max = sum[i];
            }
        }

        return max - min;
    }

    void GiveAns()
    {
        n[0] = 1;
        n[1] = 2;
        n[2] = 0;
        n[3] = 2;
        n[4] = 0;
        n[5] = 2;
        n[6] = 3;
        n[7] = 0;
        n[8] = 1;
        n[9] = 0;
    }


}
