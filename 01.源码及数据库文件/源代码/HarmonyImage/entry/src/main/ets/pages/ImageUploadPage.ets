import {User} from '../viewmodel/UserModel'
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import promptAction from '@ohos.promptAction';
// Import the new extended interface from ImageApi
import { uploadImage, FileUploadParams } from '../apis/ImageApi'
import router from '@ohos.router';
import fs from '@ohos.file.fs';

@Entry
@Component
struct ImageUploadPage {
  // 图片URI
  @State selectedImageUri: string = '';
  //患者姓名
  @State patientName: string = '';
  // 患者身份证
  @State patientIdCard: string = '';
  // 检查类型
  @State modality: string = '';
  // 标签（可选）
  @State tags: string = '';
  // 上传者信息
  @State uploader: number = 0
  // 上传状态 (避免上后端多次发送请求)
  @State isUploading: boolean = false;
  //图片选择器实例
  private photoPicker = new photoAccessHelper.PhotoViewPicker();

  aboutToAppear(): void {
    const userInfo:User|undefined = AppStorage.get<User>('currentUser')
    if(userInfo && userInfo.id){
      this.uploader = userInfo.id
    } else {
      promptAction.showToast({ message: '无法获取上传者信息，请重新登录' });
    }
  }

  isFormValid():boolean {
    return this.selectedImageUri !== '' &&
      this.patientName.trim() !== '' &&
      this.patientIdCard.trim() !== '' &&
      this.modality.trim() !== '' &&
      this.uploader !== null;
  }

  build() {
    Column() {
      Row() {
        Text('影像上传')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 32 })
      }
      .width('100%')
      .padding({ top: 15, bottom: 15, left: 5, right: 5 })
      .backgroundColor(Color.White)
      .zIndex(1)

      Scroll(){
        Column(){
          Stack({alignContent:Alignment.BottomEnd}) {
            if(this.selectedImageUri) {
              Image(this.selectedImageUri)
                .width('100%')
                .height(250)
                .objectFit(ImageFit.Contain)
                .borderRadius(10)
            } else {
              Column() {
                Text('请选择或拍摄一张医学影像')
                  .fontColor(Color.Gray)
              }
              .width('100%')
              .height(250)
              .borderRadius(10)
              .border({ width: 1, color: '#DDDDDD', style: BorderStyle.Dashed })
              .justifyContent(FlexAlign.Center)
              .onClick(() => this.selectImage())
            }
            Button(this.selectedImageUri ? '更换图片' : '选择图片')
              .margin(10)
              .onClick(() => this.selectImage())
          }
          .padding({ top: 20 })

          this.InfoInput('患者姓名', '请输入患者姓名', (value) => this.patientName = value)
          this.InfoInput('患者身份证', '请输入患者身份证号', (value) => this.patientIdCard = value)
          this.InfoInput('检查类型', '例如：CT, MRI, X-Ray 等', (value) => this.modality = value)
          this.InfoInput('标签 (可选)', '多个标签请用逗号隔开', (value) => this.tags = value)
        }.padding({ left: 15, right: 15 })
      }.layoutWeight(1)

      Button(this.isUploading ? '上传中...' : '确认上传', { type: ButtonType.Capsule, stateEffect: true })
        .width('90%')
        .height(50)
        .fontSize(18)
        .margin(20)
        .enabled(!this.isUploading && this.isFormValid())
        .backgroundColor(this.isUploading ? '#A9A9A9' : '#0D9FFB')
        .onClick(() => this.handleUpload())
    }.width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }

  async selectImage() {
    try {
      const result = await this.photoPicker.select({
        maxSelectNumber: 1,
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      });
      if (result?.photoUris?.length > 0) {
        this.selectedImageUri = result.photoUris[0];
      }
    } catch (err) {
      promptAction.showToast({ message: `选择图片失败: ${err.message}` });
    }
  }

  @Builder InfoInput(label: string, placeholder: string, onChange: (value: string) => void) {
    Column() {
      Text(label).fontSize(16).width('100%').textAlign(TextAlign.Start)
      TextInput({ placeholder: placeholder })
        .onChange(onChange)
        .padding(15)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .margin({ top: 8 })
    }
    .margin({ top: 20 })
    .width('100%')
  }

  async handleUpload() {
    if(!this.isFormValid()) {
      promptAction.showToast({message: '请填写所有必填信息'})
      return
    }

    this.isUploading = true;
    promptAction.showToast({ message: '开始上传...' });

    try {
      //打开原始文件用于获取
      const fileSource = fs.openSync(this.selectedImageUri, fs.OpenMode.READ_ONLY);

     // 从原始uri中获取文件名
      const originalFileName = this.selectedImageUri.substring(this.selectedImageUri.lastIndexOf('/') + 1) || `image_${Date.now()}.jpg`;
      const cacheFilePath = `${this.getUIContext().getHostContext()?.cacheDir}/${originalFileName}`;
      let fileDes = fs.openSync(cacheFilePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.copyFileSync(fileSource.fd, fileDes.fd);
      fs.closeSync(fileSource);
      fs.closeSync(fileDes);
      const params: FileUploadParams = {
        // 使用动态的缓存文件路径
        uri: cacheFilePath,
        // 这里的fileData可以根据您的实际需求来处理，如果只是传递uri，那它可能不是必须的
        fileData: new ArrayBuffer(10), // 注意：创建了一个大小为10的空ArrayBuffer，应该根据上面的逻辑读取实际的文件内容。
        // 使用提取出的原始文件名
        fileName: originalFileName,
        patientName: this.patientName,
        patientIdCard: this.patientIdCard,
        modality: this.modality,
        tags: this.tags,
        uploadedBy: this.uploader
      };
      const success = await uploadImage(params);

      if (success) {
        promptAction.showToast({ message: '上传成功!' });
        setTimeout(() => {
          router.back();
        }, 1000)
      }
    } catch (err) {
      promptAction.showToast({ message: `读取文件失败: ${err.message}` });
      console.error(`File read error: ${JSON.stringify(err)}`);
    } finally {
      this.isUploading = false;
    }
  }
}