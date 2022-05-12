# 序列式光學模擬系統 (Sequencial Optical System Simulation)

## 前言
這個整套系統是提供給光學透鏡模擬有興趣的朋友所寫的，希望你們用的愉快 : )。同時，我希望將這個系統可以更加完善，若在使用的過程成中，發現有誤或是更好的算法，都歡迎大家一起開發此系統。

這個系統無法像付費軟體 (CODE V 或 Zemax 等) 一樣，進行非常多功能強大的運算，內部只有最基礎的模擬功能，而功能會在之後介紹欄中各個說明。我做這個 Project 是將我在大學與研究所所學的一些光學基礎進行實踐。同時，畢業之後沒有商業軟體可以使用的情況下，自己若想玩一些小設計，勢必要自己開發一套模擬系統，基於此動機就一頭栽進去了哈哈。在開發的過程中，進行了一些 Research，發現有人也有寫光學透鏡的模擬並上傳到 Github，但原始碼非常複雜，因為大量使用 class 使程式碼難以剖析。因此，我在開發時，也盡可能減少 class 的使用，並且以 CODE V 序列式輸入光學透鏡參數的方法，方便大家進行使用，但目前還沒有做成 UI 介面，之後有時間我會再補上 : )。

---
## 介紹
此系統全部都使用 Matlab 環境開發，裡面會用到 Parallel Computing Toolbox 進行平行運算，來加速部分功能的計算效率。內部的功能包含 :

1. 光線追跡 (Ray Tracing)
2. 點列圖 (Spot Diagram)
3. 光程差分布 (Optical Path Difference)
4. 線擴散函數 (Line Spread Function)
5. 點擴散函數 (Point Spread Function)
6. 調製傳遞函數 (Modulation Transfer Function, MTF)
7. 近軸影像解 (Paraxial Image Solve)

(其中，功能 4 ~ 6 有使用到 Parallel Computing Toolbox。)

而下面我會各個介紹整體我計算的方法與功能。在此我先建立一個透鏡來做範例 : 

* Wavelength : 546.1 nm
* Object distance : infinity
* Image distance : 0.15 mm
* Lens type : Plano-Convex Lens
* Lens radius : infinity, -0.1 mm
* Lens thickness : 0.02 mm
* Material : SK16-SCHOTT (n = 1.62286)
* Entrance pupil diameter : 0.05 mm

![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/lens_demo.png)

---
### 1. 光線追跡 (Ray Tracing)
這是透鏡模擬最基本的功能，光線在入射到不同介質時，跟據司乃耳定理 (Snell's Law)，光線的入射的方向向量與入射介面的法向量夾角，稱為入射角，會受到折射率變化，在出射介面的出射角產生偏折。此系統有提供不同的視角，範例效果如下圖 : 

* XZ View
  
  ![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/lens_view_xz.png)

* YZ View
  
    ![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/lens_view_yz.png)
  
* 3D View

    ![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/lens_view_3D.png)

---
### 2. 點列圖 (Spot Diagram)
點列圖為物面的光線經過光學系統後，在像面所成像的效果。使用者可以透過點列圖來初步分析光學系統的成像品質與光學像差，如 : 球面像差 (Spherical Abberation)、彗星像差 (Coma Abberation) 與像散像差 (Astigmatism Abberation)。範例效果如下圖 : 

![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/spot_diagram.png)

---
### 3. 光程差分布 (Optical Path Difference)
此功能可以了解出射光學系統時的光程累積，並且可以換算成相位分布，使用者可以使用此功能進行像差修正的設計 (此系統不含像差修正功能)。

![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/optical_path_difference.png)

---
### 4. 線擴散函數 (Line Spread Function, LSF)
線擴散函數的計算我使用惠更斯-菲涅耳原理 (Huygens–Fresnel principle) 進行運算。將前面取得光程分布換算成相位分布，並取YZ平面的一維相位分布作為點波源的初始相位，計算出射平面的點波源到成像面的疊加，就可以得到成像面的能量分布。範例效果如下圖 :

![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/LSF.png)

---
### 5. 點擴散函數 (Point Spread Function, PSF)
PSF 與 LSF 的原理相同，區別在於使用二維相位分布。同時，我也將出射端傳播的能量分布也計算出來，並且將最高能量標記出來，可以做為最佳聚焦位置 (Best Focus)。範例效果如下圖 :

* 成像面的能量分布
  
  ![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/PSF_XY.png)

* 出射系統後的能量分布  
  
  ![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/PSF_YZ.png)

---
### 6. 調製傳遞函數 (Modulation Transfer Function, MTF)
MTF 是可以評價光學系統在成像效果的重要指標。MTF 是計算單位距離內的黑白條紋在成像面的亮度最大值與最小值的比值。隨著單位距離內的黑白條紋越多，光學系統存在繞射極限，也就是艾里斑 (Airy Disk)，意味著沒有辦法完美聚焦成一個點光源，也就代表無法做到完美成像。黑白條紋的亮度對比會逐漸下降，最後就糊成一團無法辨識。這就代表在已定的光圈 (Aperture) 大小與設計焦聚下的 Airy Disk 算得的 MTF 即為理想 MTF 值，而光學系統的 MTF 值則是使用焦平面上的能量分布進行計算。此系統是使用 LSF 計算所得到的能量分布進行快速傅立葉轉換 (Fast Fourier Transform, FFT)即可求得光學系統的 MTF。範例效果如下 :

![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/MTF.png)

上述 1 ~ 6 的功能我都有設計為開關，可以視使用者需求進行開啟或關閉，且光線追跡與 PSF 的視角切換的方法都有註解在後方。

![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/app_switch.png)

---

### 7. 近軸影像解 (Paraxial Image Solve)
這是透過光線轉換矩陣分析 (Ray Transfer Matrix Analysis)，又稱 ABCD 矩陣分析 (ABCD Matrix Analysis)。將透鏡參數按照矩陣的規則進行輸入，就可以計算出的光學系統的近軸影像解。一般的透鏡組在 CODE V 中的進軸影像解，等於後焦長 (Back Focus Length, BFL)，其定義為 : 系統最後一個光學表面頂點至後方焦點的距離。而 ABCD 矩陣不只可以計算 BFL，同時可以計算等效焦距 (Effective Focal Length)，其定義為 : 系統的後主平面 (Back Principal Plane, BPP) 到後方焦點的距離。範例計算結果會顯示在 Command Window 中 (若有計算 PSF 則會額外顯示 Best Focus 的值) :

![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/BFL_EFL.png)

而且，**我有設計近軸影像解的開關，若在輸入透鏡參數不知道成像面要設定多遠時，可以先設把最後一個平面的 thickness 設為 0 ，並且將 Parameter Setting 的 Use_Paraxial_Solve 的參數設為 1 (ON)，系統將會自動把 EFL 值帶入。**

**但使用者想要自己設定成像面，要記得把 Use_Paraxial_Solve 的參數設為 0 (OFF)。**

---

## 系統與 CODE V 的比較

按照上述的範例將參數輸入進 CODE V 中，如下圖 : 

![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/vs_CODEV/CODEV_setting_1.png)
![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/vs_CODEV/CODEV_setting_2.png)

![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/vs_CODEV/CODEV_setting.png)

可以看到近軸影像解顯示 0.1605 mm，同時，BFL 與 EFL 都等於 0.1605 mm。

而這次我將我的 Use_Paraxial_Solve 的參數設為 1 (ON) 後，計算的結果與 CODE V 進行比較 : 

### 光線追跡 (Ray Tracing)

![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/vs_CODEV/CODEV_lens_view_yz.png)
![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/vs_CODEV/SOSS_lens_view_yz.png)

### 點列圖 (Spot Diagram)

![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/vs_CODEV/CODEV_spot_diagram.png)
![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/vs_CODEV/SOSS_spot_diagram.png)

### 線擴散函數 (LSF)

![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/vs_CODEV/CODEV_LSF.png)
![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/vs_CODEV/SOSS_LSF.png)

### 點擴散函數 (PSF)

![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/vs_CODEV/CODEV_PSF.png)
![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/vs_CODEV/SOSS_PSF.png)

### 調製傳遞函數 (MTF)

![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/vs_CODEV/CODEV_MTF.png)
![image](https://github.com/YiChenLai/Sequencial_Optical_System_Simulation/blob/master/image/vs_CODEV/SOSS_MTF.png)
