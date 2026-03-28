import { searchImages } from '../apis/ImageApi';
import ReportApi from '../apis/ReportApi';
import { Image } from '../viewmodel/ImageModel';
import { Report } from '../viewmodel/ReportModel';
import { ImageSearchParams } from '../params/request/ImageSearchParams';
import promptAction from '@ohos.promptAction';
import { JSON } from '@kit.ArkTS';

/**
 * 查看和编辑报告的弹窗
 */
@CustomDialog
struct ReportEditDialog {
  controller: CustomDialogController;
  // 使用@Link实现双向绑定，确保父组件的状态同步更新
  @Link report: Report;
  @Link isEditMode: boolean; // true为编辑模式, false为查看模式
  // 定义一个回调函数，用于在更新成功后通知父组件刷新列表
  onUpdateSuccess: () => void = () => {};

  // 弹窗提交逻辑
  async handleSubmit() {
    if (!this.report.diagnosis || !this.report.suggestion) {
      promptAction.showToast({ message: '诊断结论和治疗建议不能为空' });
      return;
    }
    try {
      const response = await ReportApi.updateReport(this.report);
      if (response.state === 200) {
        promptAction.showToast({ message: '报告更新成功' });
        this.onUpdateSuccess(); // 调用回调刷新父页面
        this.controller.close();
      } else {
        promptAction.showToast({ message: response.message || '更新失败' });
      }
    } catch (error) {
      promptAction.showToast({ message: `更新失败: ${error}` });
    }
  }

  build() {
    Column() {
      Text(this.isEditMode ? '编辑报告' : '报告详情')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      Scroll() {
        Column({ space: 10 }) {
          TextInput({ text: `报告ID: ${this.report.id}` }).enabled(false)
          TextInput({ text: `影像ID: ${this.report.imageId}` }).enabled(false)
          Divider()

          Text('诊断结论').fontSize(16).width('100%').textAlign(TextAlign.Start)
          TextArea({ text: this.report.diagnosis, placeholder: '请输入诊断结论' })
            .height(100)
            .enabled(this.isEditMode)
            .onChange((value) => { this.report.diagnosis = value; })

          Text('治疗建议').fontSize(16).width('100%').textAlign(TextAlign.Start)
          TextArea({ text: this.report.suggestion, placeholder: '请输入治疗建议' })
            .height(100)
            .enabled(this.isEditMode)
            .onChange((value) => { this.report.suggestion = value; })

          Text('详细内容').fontSize(16).width('100%').textAlign(TextAlign.Start)
          TextArea({ text: this.report.content, placeholder: '请输入详细内容' })
            .height(150)
            .enabled(this.isEditMode)
            .onChange((value) => { this.report.content = value; })
        }
      }
      .layoutWeight(1)


      Row({ space: 10 }) {
        Button('关闭')
          .onClick(() => this.controller.close())
          .layoutWeight(1)
          .backgroundColor(Color.Gray)

        if (this.isEditMode) {
          Button('保存')
            .onClick(() => this.handleSubmit())
            .layoutWeight(1)
        }
      }
      .width('100%')
      .margin({ top: 20 })
    }
    .padding(20)
    .width('95%')
  }
}

@Entry
@Component
struct ReportQueryPage {
  // 影像搜索表单
  @State patientName: string = '';
  @State patientIdCard: string = '';
  @State modality: string = '';

  // 列表数据
  @State imageList: Image[] = [];
  @State reportList: Report[] = [];

  // 状态控制
  @State isImageLoading: boolean = false;
  @State isReportLoading: boolean = false;
  @State selectedImage: Image | null = null;
  @State currentReport: Report = new Report(0, 0); // 用于弹窗的报告对象

  @State isDialogEditMode: boolean = false;

  // 弹窗控制器
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: ReportEditDialog({
      report: $currentReport,
      isEditMode: $isDialogEditMode, // 默认是查看模式
      onUpdateSuccess: () => {
        // 更新成功后，重新加载报告列表
        if (this.selectedImage) {
          this.loadReportsForImage(this.selectedImage);
        }
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });

  // 搜索影像
  async performSearch() {
    this.isImageLoading = true;
    this.imageList = [];
    this.reportList = [];
    this.selectedImage = null;

    const params: ImageSearchParams = {
      patientName: this.patientName,
      patientIdCard: this.patientIdCard,
      modality: this.modality,
    };

    try {
      const response = await searchImages(params);
      this.imageList = response;
      if (this.imageList.length === 0) {
        promptAction.showToast({ message: '未找到相关影像' });
      }
    } catch (e) {
      promptAction.showToast({ message: `搜索影像失败: ${e}` });
    } finally {
      this.isImageLoading = false;
    }
  }

  // 加载影像对应的报告
  async loadReportsForImage(image: Image) {
    this.selectedImage = image;
    this.isReportLoading = true;
    this.reportList = [];

    try {
      const response = await ReportApi.getReportsByImageId(image.id);
      console.log(JSON.stringify(response))
      if (response.state === 0) {
        this.reportList = response.data;
      } else {
        promptAction.showToast({ message: response.message || '加载报告失败' });
      }
    } catch (e) {
      promptAction.showToast({ message: `加载报告失败: ${e}` });
    } finally {
      this.isReportLoading = false;
    }
  }

  // 打开弹窗
  openDialog(report: Report, isEdit: boolean) {
    // 创建副本以避免直接修改列表中的原始数据
    const reportCopy = new Report(report.imageId, report.generatedBy);
    reportCopy.id = report.id;
    reportCopy.diagnosis = report.diagnosis;
    reportCopy.suggestion = report.suggestion;
    reportCopy.content = report.content;
    reportCopy.createdAt = report.createdAt;

    this.currentReport = reportCopy;
    this.isDialogEditMode = isEdit;
    this.dialogController.open();
  }

  // 删除报告
  async handleDelete(reportId: number) {
    try {
      const result = await promptAction.showDialog({
        title: '确认删除',
        message: `您确定要删除ID为 ${reportId} 的报告吗？此操作无法撤销。`,
        buttons: [
          {
            text: '取消',
            color: '#000000'
          },
          {
            text: '确定',
            color: '#FF0000'
          }
        ]
      });

      if (result.index === 1) {
        try {
          const response = await ReportApi.deleteReport(reportId);
          if (response.state === 200) {
            promptAction.showToast({ message: '删除成功' });
            // 刷新报告列表
            if (this.selectedImage) {
              this.loadReportsForImage(this.selectedImage);
            }
          } else {
            promptAction.showToast({ message: response.message || '删除失败' });
          }
        } catch (e) {
          promptAction.showToast({ message: `网络请求异常: ${e.message}` });
        }
      } else {
        // 用户点击了“取消”或者关闭了对话框
        console.info('用户取消了删除操作。');
      }
    } catch (error) {
      // 处理 showDialog 本身可能出现的错误
      console.error(`显示删除确认对话框时出错: ${JSON.stringify(error)}`);
    }
  }


  build() {
    Column() {
      // 搜索区域
      Column() {
        Text('报告查询与管理').fontSize(24).fontWeight(FontWeight.Bold).margin({ bottom: 10 })
        TextInput({ placeholder: '患者姓名' }).onChange(val => this.patientName = val)
        TextInput({ placeholder: '患者身份证' }).onChange(val => this.patientIdCard = val).margin({ top: 5, bottom: 5 })
        TextInput({ placeholder: '影像类型' }).onChange(val => this.modality = val)
        Button('查询影像', { type: ButtonType.Capsule })
          .width('100%')
          .margin({ top: 10 })
          .onClick(() => this.performSearch())
      }
      .padding(15)
      .backgroundColor(Color.White)
      .borderRadius(15)
      .shadow({ radius: 6, color: '#1F000000' })


      // 影像列表
      Text('影像列表 (请选择一项以查看报告)')
        .fontSize(16)
        .margin({ top: 20, bottom: 5 })
        .width('90%')
        .textAlign(TextAlign.Start)

      if (this.isImageLoading) {
        LoadingProgress().width(50).margin(20)
      } else {
        List({ space: 10 }) {
          ForEach(this.imageList, (image: Image) => {
            ListItem() {
              this.ImageRow(image)
            }
            .backgroundColor(this.selectedImage?.id === image.id ? '#e0f3ff' : Color.White)
            .onClick(() => this.loadReportsForImage(image))
          })
        }
        .layoutWeight(1)
        .width('90%')
        .borderRadius(10)
      }
      // 报告列表
      Text('报告列表')
        .fontSize(16)
        .margin({ top: 20, bottom: 5 })
        .width('90%')
        .textAlign(TextAlign.Start)

      if (this.isReportLoading) {
        LoadingProgress().width(50).margin(20)
      } else {
        List({ space: 10 }) {
          ForEach(this.reportList, (report: Report) => {
            ListItem() {
              this.ReportRow(report)
            }
          })
        }
        .layoutWeight(1)
        .width('90%')
        .borderRadius(10)
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 10, right: 10, top: 15, bottom: 15 })
    .backgroundColor('#f5f5f5')
  }

  // 影像列表项的UI构建器
  @Builder ImageRow(image: Image) {
    Row() {
      Column({ space: 5 }) {
        Text(`患者: ${image.patientName}`).fontWeight(FontWeight.Bold)
        Text(`影像类型: ${image.modality}`)
      }.alignItems(HorizontalAlign.Start)
    }
    .padding(10)
    .borderRadius(8)
    .width('100%')
  }

  // 报告列表项的UI构建器
  @Builder ReportRow(report: Report) {
    Row() {
      Column({ space: 5 }) {
        Text(`报告ID: ${report.id}`).fontWeight(FontWeight.Bold)
        Text(`诊断结论: ${report.diagnosis.substring(0, 20)}...`)
          .fontColor(Color.Gray)
      }.alignItems(HorizontalAlign.Start).layoutWeight(1)

      // 操作按钮
      Button('查看')
        .size({ width: 60, height: 35 })
        .onClick(() => this.openDialog(report, false))
      Button('编辑')
        .size({ width: 60, height: 35 })
        .margin({ left: 5 })
        .onClick(() => this.openDialog(report, true))
      Button('删除')
        .size({ width: 60, height: 35 })
        .margin({ left: 5 })
        .fontColor(Color.White)
        .backgroundColor(Color.Red)
        .onClick(() => {
          if (report.id !== null) {
            this.handleDelete(report.id);
          } else {
            promptAction.showToast({ message: '此报告没有有效ID，无法删除' });
          }
        })
    }
    .padding(10)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .width('100%')
  }
}