using FlutterUnityIntegration;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class CarCore : MonoBehaviour
{
    //=============================================================================================
    [SerializeField][ReadOnly] private WheelDataHandler SelectedWheel;
    [SerializeField] private UnityMessageManager UnityMessageManager;

    [Header("SELECTED WHEEL VARIABLES")]
    [SerializeField] private TextMeshProUGUI SelectedWheelNameTMP;
    [SerializeField] private TextMeshProUGUI PriceTMP;
    [SerializeField] private Button AddToCartBtn;

    [Header("AVAILABLE WHEELS")]
    [SerializeField] private List<WheelDataHandler> allWheelHandlers;
    //=============================================================================================

    public void InitializeCarScene()
    {
        SelectedWheelNameTMP.text = "SELECT YOUR WHEEL";
        PriceTMP.text = "";
        AddToCartBtn.interactable = false;
    }

    public void SetSelectedWheel(WheelDataHandler wheelDataHandler)
    {
        SelectedWheel = wheelDataHandler;
        SelectedWheelNameTMP.text = SelectedWheel.wheelData.productName;
        PriceTMP.text = "PHP " + SelectedWheel.wheelData.price.ToString("n0");
        AddToCartBtn.interactable = true;
        foreach (var wheel in allWheelHandlers)
            wheel.HideWheel();
        SelectedWheel.DisplayWheel();
    }

    public void SendMessageToFlutter()
    {
        UnityMessageManager.SendMessageToFlutter(SelectedWheel.wheelData.productID);
    }
}
