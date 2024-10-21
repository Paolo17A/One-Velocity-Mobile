using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StartCore : MonoBehaviour
{
    //=============================================================================================

    [Header("FLOATING LOGO")]
    [SerializeField] private GameObject floatingLogo;
    [SerializeField] private float minYValue;
    [SerializeField] private float maxYValue;
    [SerializeField] private float floatSpeed;

    [ReadOnly] public bool isGoingUp;
    //=============================================================================================

    public void TweenFloatLogo()
    {
        if (floatingLogo == null)
            return;    

        if (isGoingUp)
        {
            if (Mathf.Abs(floatingLogo.transform.position.y - maxYValue) > Mathf.Epsilon)
            {
                floatingLogo.transform.position = Vector3.MoveTowards(floatingLogo.transform.position,
                new Vector3(floatingLogo.transform.position.x, maxYValue, floatingLogo.transform.position.z),
                floatSpeed * Time.deltaTime);
            }
            else 
                isGoingUp = false;
        }
        else
        {
            if (Mathf.Abs(floatingLogo.transform.position.y - minYValue) > Mathf.Epsilon)
            {
                floatingLogo.transform.position = Vector3.MoveTowards(floatingLogo.transform.position,
               new Vector3(floatingLogo.transform.position.x, minYValue, floatingLogo.transform.position.z),
               floatSpeed * Time.deltaTime);
            }
            else
                isGoingUp = true;
        }
    }

    public void GoToCarScene()
    {
        UnityGameManager.Instance.SceneController.CurrentScene = "CarScene";
    }

    public void ReturnToApp()
    {
        UnityGameManager.Instance.UnityMessageManager.SendMessageToFlutter("QUIT");
    }
}
