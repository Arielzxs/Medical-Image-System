import { searchImages } from '../apis/ImageApi';
import { Image } from '../viewmodel/ImageModel';
import { ImageSearchParams } from '../params/request/ImageSearchParams';
import { Report } from '../viewmodel/ReportModel';
import ReportApi from '../apis/ReportApi';
import promptAction from '@ohos.promptAction';


//自定义弹窗
@CustomDialog
struct CreateReportDialog {
  controller: CustomDialogController
  //实现页面与弹窗数据的双向绑定
  @Link reportForm: Report;
  onSubmit: () => Promise<void> = async () => {};

  build() {
    Column() {
      Text('新建报告').fontSize(20).fontWeight(FontWeight.Bold).margin({ bottom: 15 })

      // 禁用的影像ID输入框
      TextInput({ text: `影像ID: ${this.reportForm.imageId}` })
        .enabled(false)
        .margin({ bottom: 10 })

      // 表单项
      TextArea({ placeholder: '诊断结论', text: this.reportForm.diagnosis })
        .onChange((value) => { this.reportForm.diagnosis = value; })
        .height(100)
        .margin({ bottom: 10 })

      TextArea({ placeholder: '治疗建议', text: this.reportForm.suggestion })
        .onChange((value) => { this.reportForm.suggestion = value; })
        .height(100)
        .margin({ bottom: 10 })

      TextArea({ placeholder: '详细内容', text: this.reportForm.content })
        .onChange((value) => { this.reportForm.content = value; })
        .height(150)
        .margin({ bottom: 20 })

      // 底部按钮
      Row() {
        Button('取消')
          .onClick(() => this.controller.close())
          .layoutWeight(1)
          .backgroundColor(Color.Gray)

        Button('提交')
          .onClick(async () => {
            await this.onSubmit();
            // 在父组件的onSubmit成功后关闭弹窗
          })
          .layoutWeight(1)
          .margin({ left: 10 })

      }.width('100%')
    }
    .padding(20)
    .width('90%')
  }
}


@Entry
@Component
struct CreateReportPage {
  @State patientName: string = '';
  @State patientIdCard: string = '';
  @State modality: string = '';
  @State tags: string = '';
  @State startDate: Date = new Date();
  @State endDate: Date = new Date();
  @State isStartDateEnabled: boolean = false;
  @State isEndDateEnabled: boolean = false;

  @State imageList: Image[] = [];
  @State isLoading: boolean = false;
  @State searchMessage: string = '请先搜索并选择一张影像以创建报告';

  @State selectedImage: Image | null = null;
  @State reportForm: Report = new Report(0, 1); // 假设当前用户ID为1

  //创建弹出框对象
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: CreateReportDialog({
      reportForm: $reportForm,
      onSubmit: this.handleDialogSubmit.bind(this)
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });


  // 执行搜索
  async performSearch() {
    this.isLoading = true;
    this.searchMessage = '';
    this.selectedImage = null; // 重置已选影像

    const params: ImageSearchParams = {
      patientName: this.patientName,
      patientIdCard: this.patientIdCard,
      modality: this.modality,
      tags: this.tags
    };

    if (this.isStartDateEnabled) params.startDate = this.startDate.toISOString();
    if (this.isEndDateEnabled) params.endDate = this.endDate.toISOString();

    try {
      const results = await searchImages(params);
      this.imageList = results;
      if (results.length === 0) {
        this.searchMessage = '未找到符合条件的影像';
      }
    } catch (error) {
      this.searchMessage = '搜索失败，请检查网络';
    } finally {
      this.isLoading = false;
    }
  }

  // 打开创建报告弹窗
  openCreateDialog() {
    if (!this.selectedImage) {
      promptAction.showToast({ message: '请先选择一张影像' });
      return;
    }
    // 使用选定的影像ID初始化报告表单
    this.reportForm = new Report(this.selectedImage.id, 1); // 假设当前用户ID为1
    this.dialogController.open();
  }

  // 提交报告
  async handleDialogSubmit() {
    try {
      const message = await ReportApi.createReport(this.reportForm);
      promptAction.showToast({ message:  '报告创建成功' });
      this.dialogController.close(); // 成功后关闭弹窗
    } catch (error) {
      promptAction.showToast({ message: `报告创建失败: ${error}` });
    }
  }


  build() {
    Column() {
      // 页面标题和新建报告按钮
      Row({ space: 10 }) {
        Text('创建报告')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
        Blank() // 占据剩余空间
        Button('新建报告')
          .onClick(() => this.openCreateDialog())
          .enabled(this.selectedImage !== null) // 仅在选择影像后可用
          .type(ButtonType.Capsule)

      }
      .width('90%')
      .margin({ top: 20, bottom: 10 })
      .alignItems(VerticalAlign.Center)


      // 搜索表单
      Column() {
        TextInput({ placeholder: '患者姓名' }).onChange((value) => {
          this.patientName = value;
        }).margin({ bottom: 5 })

        TextInput({ placeholder: '患者身份证' }).onChange((value) => {
          this.patientIdCard = value;
        }).margin({ bottom: 5 })

        TextInput({ placeholder: '影像类型 (e.g., CT)' }).onChange((value) => {
          this.modality = value;
        }).margin({ bottom: 5 })

        TextInput({ placeholder: '影像标签 (e.g., 头部)' }).onChange((value) => {
          this.tags = value;
        }).margin({ bottom: 5 })

        // 日期选择
        // 开始日期
        Row({ space: 10 }) {
          Toggle({ type: ToggleType.Switch, isOn: this.isStartDateEnabled })
            .onChange((isOn) => { this.isStartDateEnabled = isOn; })
          Text('开始日期').fontColor(this.isStartDateEnabled ? Color.Black : Color.Gray)
          if (this.isStartDateEnabled) {
            DatePicker({
              start: new Date('2020-01-01'),
              end: new Date('2099-12-31'),
              selected: this.startDate
            })
              .onChange((date) => {
                const now = new Date();
                this.startDate = new Date(
                  date.year ?? now.getFullYear(),
                  date.month ?? now.getMonth(),
                  date.day ?? now.getDate()
                );
              })
          }
        }.width('100%').justifyContent(FlexAlign.Start).margin({bottom: 5})

        // 结束日期
        Row({ space: 10 }) {
          Toggle({ type: ToggleType.Switch, isOn: this.isEndDateEnabled })
            .onChange((isOn) => { this.isEndDateEnabled = isOn; })
          Text('结束日期').fontColor(this.isEndDateEnabled ? Color.Black : Color.Gray)
          if (this.isEndDateEnabled) {
            DatePicker({
              start: new Date('2020-01-01'),
              end: new Date('2099-12-31'),
              selected: this.endDate
            })
              .onChange((date) => {
                const now = new Date();
                this.endDate = new Date(
                  date.year ?? now.getFullYear(),
                  date.month ?? now.getMonth(),
                  date.day ?? now.getDate()
                );
              })
          }
        }.width('100%').justifyContent(FlexAlign.Start).margin({ bottom: 10 })

        Button('查询')
          .onClick(() => {
            this.performSearch();
          })
          .width('80%')
          .margin({ bottom: 20 })
      }
      .width('90%')
      .padding(15)
      .backgroundColor(Color.White)
      .borderRadius(10)
      .shadow({ radius: 5, color: '#f0f0f0' })
      .margin({ bottom: 20 })


      // 结果列表
      List({ space: 10 }) {
        ForEach(
          this.imageList,
          (item: Image) => {
            ListItem() {
              this.ImageRow(item)
            }
            .onClick(() => {
              this.selectedImage = item;
              promptAction.showToast({ message: `已选择: ${item.patientName}的影像` })
            })
            // 高亮显示选中的行
            .backgroundColor(this.selectedImage?.id === item.id ? '#e0e0e0' : Color.White)
          },
          (item: Image) => (item.id ?? item.filePath).toString()
        )
      }
      .divider({ strokeWidth: 1, color: '#f0f0f0' })
      .layoutWeight(1) // 占据剩余空间
      .width('90%')

      // 加载中或无结果提示
      if (this.isLoading) {
        Text('正在加载中...').fontSize(16).margin(20)
      } else if (this.imageList.length === 0) {
        Text(this.searchMessage).fontSize(16).fontColor(Color.Gray).margin(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  // 单个影像的显示组件
  @Builder ImageRow(image: Image) {
    Row() {
      Image("http://172.20.10.5:8081" + image.filePath)
        .width(80)
        .height(80)
        .borderRadius(10)
        .objectFit(ImageFit.Cover)
        .margin({ right: 15 })

      Column() {
        Text(`患者: ${image.patientName || 'N/A'}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
        Text(`类型: ${image.modality || 'N/A'}`)
          .fontSize(14)
          .fontColor(Color.Gray)
        Text(`上传者: ${image.uploadedName || 'N/A'}`)
          .fontSize(14)
          .fontColor(Color.Gray)
        Text(`时间: ${image.uploadedAt ? new Date(image.uploadedAt).toLocaleString() : 'N/A'}`)
          .fontSize(12)
          .fontColor(Color.Gray)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .padding(10)
    .width('100%')
  }
}