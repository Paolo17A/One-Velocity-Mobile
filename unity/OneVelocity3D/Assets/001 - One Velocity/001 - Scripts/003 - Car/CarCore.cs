using FlutterUnityIntegration;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class CarCore : MonoBehaviour
{
    #region STATE MACHINE
    //=============================================================================================
    public enum CarStates
    {
        NONE,
        CARS,
        OPTIONS,
        WHEELS,
        COLORS,
        CONFIRM,
        DONE
    }

    private event EventHandler carStateChange;
    public event EventHandler onCarStateChange
    {
        add
        {
            if (carStateChange == null || !carStateChange.GetInvocationList().Contains(value))
                carStateChange += value;
        }
        remove { carStateChange -= value; }
    }

    public CarStates CurrentCarState
    {
        get => carStates;
        set
        {
            carStates = value;
            carStateChange?.Invoke(this, EventArgs.Empty);
        }
    }
    [SerializeField][ReadOnly] private CarStates carStates;
    //=============================================================================================
    #endregion

    #region VARIABLES
    //=============================================================================================
    [Header("PANELS")]
    [SerializeField] private RectTransform CarSelectRT;
    [SerializeField] private CanvasGroup CarSelectCG;
    [SerializeField] private RectTransform OptionSelectRT;
    [SerializeField] private CanvasGroup OptionSelectCG;
    [SerializeField] private RectTransform WheelSelectRT;
    [SerializeField] private CanvasGroup WheelSelectCG;
    [SerializeField] private RectTransform ColorSelectRT;
    [SerializeField] private CanvasGroup ColorSelectCG;
    [SerializeField] private RectTransform ConfirmRT;
    [SerializeField] private CanvasGroup ConfirmCG;
    [SerializeField] private RectTransform DoneRT;
    [SerializeField] private CanvasGroup DoneCG;

    [Header("ALL STATES VARIABLES")]
    [SerializeField] private TextMeshProUGUI SelectedCarNameTMP;
    [SerializeField] private TextMeshProUGUI SelectedItemTMP;
    [SerializeField] private TextMeshProUGUI SelectedPriceTMP;
    [SerializeField][ReadOnly] private bool DoingBoth;

    [Header("CAR SELECT VARIABLES")]
    [SerializeField] private List<GameObject> CarModels;
    [SerializeField] private Button SelectCarBtn;

    [Header("WHEEL SELECT VARIABLES")]
    [SerializeField][ReadOnly] private WheelDataHandler SelectedWheel;
    [SerializeField][ReadOnly] private ColorSelector SelectedColorSelector;
    [SerializeField] private UnityMessageManager UnityMessageManager;
    [SerializeField] private List<WheelDataHandler> allWheelHandlers;
    [SerializeField] private Button SelectWheelBtn;

    [Header("COLOR SELECT VARIABLES")]
    [SerializeField] private Material SelectedMaterial;
    [SerializeField] private Button SelectColorBtn;

    [Header("CONFIRM VARIABLES")]
    [SerializeField][ReadOnly] private bool isDisplayingWheels;
    [SerializeField] private TextMeshProUGUI ConfirmMessageTMP;
    //=============================================================================================
    #endregion

    #region PANELS
    public void ShowCarSelectPanel()
    {
        ResetCarColor();
        UnityGameManager.Instance.AnimationsLT.FadePanel(CarSelectRT, null, CarSelectCG, 0, 1, () => { });
    }

    public void HideCarSelectPanel()
    {
        UnityGameManager.Instance.AnimationsLT.FadePanel(CarSelectRT, CarSelectRT, CarSelectCG, 1, 0, () => { });
    }

    public void ShowOptionsPanel()
    {
        HideAllWheels();
        ResetCarColor();
        UnityGameManager.Instance.AnimationsLT.FadePanel(OptionSelectRT, null, OptionSelectCG, 0, 1, () => { });
    }

    public void HideOptionsPanel()
    {
        UnityGameManager.Instance.AnimationsLT.FadePanel(OptionSelectRT, OptionSelectRT, OptionSelectCG, 1, 0, () => { });
    }

    public void ShowWheelsPanel()
    {
        UnityGameManager.Instance.AnimationsLT.FadePanel(WheelSelectRT, null, WheelSelectCG, 0, 1, () => { });
    }

    public void HideWheelsPanel()
    {
        UnityGameManager.Instance.AnimationsLT.FadePanel(WheelSelectRT, WheelSelectRT, WheelSelectCG, 1, 0, () => { });
    }

    public void ShowColorsPanel()
    {
        UnityGameManager.Instance.AnimationsLT.FadePanel(ColorSelectRT, null, ColorSelectCG, 0, 1, () => { });
    }

    public void HideColorsPanel()
    {
        UnityGameManager.Instance.AnimationsLT.FadePanel(ColorSelectRT, ColorSelectRT, ColorSelectCG, 1, 0, () => { });
    }

    public void ShowConfirmPanel()
    {
        if(DoingBoth)
            ConfirmMessageTMP.text = "Do you wish to add " + SelectedWheel.wheelData.productName + " and " + SelectedColorSelector.paintJobData.serviceName + " to your carts?";
        else
            ConfirmMessageTMP.text = "Do you wish to add " + SelectedItemTMP.text + " to your cart?";
        UnityGameManager.Instance.AnimationsLT.FadePanel(ConfirmRT, null, ConfirmCG, 0, 1, () => { });
    }

    public void HideConfirmPanel()
    {
        UnityGameManager.Instance.AnimationsLT.FadePanel(ConfirmRT, ConfirmRT, ConfirmCG, 1, 0, () => { });
    }

    public void ShowDonePanel()
    {
        HideAllCarModels();
        HideAllWheels();
        SelectedCarNameTMP.gameObject.SetActive(false);
        SelectedItemTMP.gameObject.SetActive(false);
        SelectedPriceTMP.gameObject.SetActive(false);
        UnityGameManager.Instance.AnimationsLT.FadePanel(DoneRT, null, DoneCG, 0, 1, () => { });
    }

    public void HideDonePanel()
    {
        UnityGameManager.Instance.AnimationsLT.FadePanel(DoneRT, DoneRT, DoneCG, 1, 0, () => { });
    }

    public void CarStateToIndex(int index)
    {
        switch (index)
        {
            case (int)CarStates.CARS:
                CurrentCarState = CarStates.CARS;
                break;
            case (int)CarStates.OPTIONS:
                CurrentCarState = CarStates.OPTIONS;
                break;
            case (int)CarStates.WHEELS:
                CurrentCarState = CarStates.WHEELS;
                break;
            case (int)CarStates.COLORS:
                CurrentCarState = CarStates.COLORS;
                break;
            case (int)CarStates.CONFIRM:
                CurrentCarState = CarStates.CONFIRM;
                break;
            case (int)CarStates.DONE:
                CurrentCarState = CarStates.DONE;
                break;
        }
    }
    #endregion

    #region GLOBAL TEXT
    public void ToggleSelectedItemText(bool value)
    {
        SelectedItemTMP.gameObject.SetActive(value);
        SelectedPriceTMP.gameObject.SetActive(value);
    }
    #endregion

    #region CARS
    public void InitializeCarScene()
    {
        SelectCarBtn.gameObject.SetActive(false);
        ToggleSelectedItemText(false);
        HideAllCarModels();
        HideAllWheels();
        ResetCarColor();
    }
    public void HideAllCarModels()
    {
        foreach(GameObject car in CarModels)
            car.SetActive(false);
    }

    public void SetSelectedCarName(string name)
    {
        SelectedCarNameTMP.text = name;
        SelectCarBtn.gameObject.SetActive(true);
        SelectedCarNameTMP.gameObject.SetActive(true);
    }

    public void ResetCarColor()
    {
        SelectedMaterial.color = Color.white;
    }
    #endregion

    #region OPTIONS
    public void SelectBothWheelsAndPaint()
    {
        DoingBoth = true;
        HideOptionsPanel();
        CurrentCarState = CarStates.WHEELS;
    }

    public void DeselectBothWheelsAndPaint()
    {
        DoingBoth = false;
    }
    #endregion

    #region WHEELS
    public void SetSelectedWheel(WheelDataHandler wheelDataHandler)
    {
        SelectedWheel = wheelDataHandler;
        SelectedItemTMP.gameObject.SetActive(true);
        SelectedItemTMP.text = SelectedWheel.wheelData.productName;
        SelectedPriceTMP.gameObject.SetActive(true);
        SelectedPriceTMP.text = "PHP " + SelectedWheel.wheelData.price.ToString("n0");
        HideAllWheels();
        SelectedWheel.DisplayWheel();
        SelectWheelBtn.gameObject.SetActive(true);  
    }

    public void HideAllWheels()
    {
        foreach (var wheel in allWheelHandlers)
            wheel.HideWheel();
    }

    public void GoToPanelAfterWheels()
    {
        HideWheelsPanel();
        if (DoingBoth)
            CurrentCarState = CarStates.COLORS;
        else
            CurrentCarState = CarStates.CONFIRM;
    }

    public void DisplayRandomWheel()
    {
        int randomIndex = UnityEngine.Random.Range(0,allWheelHandlers.Count);
        allWheelHandlers[randomIndex].DisplayWheel();
    }
    #endregion

    #region COLOR
    public void SetSelectedPaintJob(ColorSelector colorSelector)
    {
        SelectedColorSelector = colorSelector;
        SelectedItemTMP.gameObject.SetActive(true);
        SelectedPriceTMP.gameObject.SetActive(true);
        if (DoingBoth)
        {
            SelectedItemTMP.text += "\n" + SelectedColorSelector.paintJobData.serviceName;
            SelectedPriceTMP.text += "\n" + "PHP " + SelectedColorSelector.paintJobData.price.ToString("n0");
        }
        else
        {
            SelectedItemTMP.text = SelectedColorSelector.paintJobData.serviceName;
            SelectedPriceTMP.text = "PHP " + SelectedColorSelector.paintJobData.price.ToString("n0");
        }
        
        SetSelectedMaterialColor(SelectedColorSelector.paintJobData.color);
        SelectColorBtn.gameObject.SetActive(true);  
    }

    public void SetSelectedMaterialColor(Color color)
    {
        SelectedMaterial.color = color; 
    }

    public void LeaveColorsPanel()
    {
        HideColorsPanel();
        ResetCarColor();
        HideAllWheels();
        if (DoingBoth)
        {
            CurrentCarState = CarStates.WHEELS;
            ToggleSelectedItemText(true);
            SelectedItemTMP.text = SelectedColorSelector.paintJobData.serviceName;
            SelectedPriceTMP.text = "PHP " + SelectedColorSelector.paintJobData.price.ToString("n0");
        }
        else
        {
            ToggleSelectedItemText(false);
            CurrentCarState = CarStates.OPTIONS;
        }
    }
    #endregion

    #region CONFIRM
    public void SetIsDisplayingWheels(bool value)
    {
        isDisplayingWheels = value;
    }

    public void SendMessageToFlutter()
    {
        if (DoingBoth)
        {
            UnityMessageManager.SendMessageToFlutter("PRODUCT/" + SelectedWheel.wheelData.productID);
            UnityMessageManager.SendMessageToFlutter("SERVICE/" + SelectedColorSelector.paintJobData.serviceID);
        }
        else
        {
            if (isDisplayingWheels)
                UnityMessageManager.SendMessageToFlutter("PRODUCT/" + SelectedWheel.wheelData.productID);
            else
                UnityMessageManager.SendMessageToFlutter("SERVICE/" + SelectedColorSelector.paintJobData.serviceID);
        }
        HideConfirmPanel();
        CurrentCarState = CarStates.DONE;
    }

    public void LeaveConfirmPanel()
    {
        HideConfirmPanel();
        if (isDisplayingWheels)
            CurrentCarState = CarStates.WHEELS;
        else
            CurrentCarState = CarStates.COLORS;
    }

    public void ExitCarScene()
    {
        UnityGameManager.Instance.SceneController.CurrentScene = "StartScene";
    }
    #endregion


}
