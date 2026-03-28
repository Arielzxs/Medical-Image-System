import { deleteLog, getLogPage } from '../apis/LogApi';
import LogModel from '../viewmodel/LogModel';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import {LogSearchParams} from '../params/request/LogSearchParams'
@Entry
@Component
struct OperationLogPage {
  @State searchUsername: string = '';
  @State searchOperation: string = '';
  @State dateRange: [Date, Date] | null = null;
  @State logs: Array<LogModel> = [];
  @State pageNo: number = 1;
  @State pageSize: number = 5;
  @State total: number = 0;
  @State loading: boolean = false;

  aboutToAppear() {
    this.fetchLogs();
  }

  async fetchLogs() {
    this.loading = true;
    const params:LogSearchParams = {
        pageNo: this.pageNo,
        pageSize: this.pageSize,
        username: this.searchUsername,
        operation: this.searchOperation,
        startDate: this.dateRange ? this.dateRange[0].toISOString() : '',
        endDate: this.dateRange ? this.dateRange[1].toISOString() : ''
    };
    const result = await getLogPage(params);
    this.logs = result.records;
    this.total = result.total;
    this.loading = false;
  }

  async handleSearch() {
    this.pageNo = 1;
    await this.fetchLogs();
  }

  async handleReset() {
    this.searchUsername = '';
    this.searchOperation = '';
    this.dateRange = null;
    await this.handleSearch();
  }

  async handleDelete(logId: number) {
      const confirm = await promptAction.showDialog({
        title: '警告',
        message: '确定要删除这条日志吗?',
        buttons: [
          { text: '取消', color: '#000000' },
          { text: '确定', color: '#FF0000' }
        ]
      });

    if (confirm.index === 1) {
      const success = await deleteLog(logId);
      if (success) {
        promptAction.showToast({ message: '删除成功' });
        if (this.logs.length === 1 && this.pageNo > 1) {
          this.pageNo--;
        }
        await this.fetchLogs();
      } else {
        promptAction.showToast({ message: '删除失败' });
      }
    }

  }

  build() {
    Column() {
      // 标题
      Row() {
        Text('用户操作日志')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }.padding({ left: 10, right: 50, top:10, bottom:10 })

      // 搜索区域
      Column() {
        TextInput({ placeholder: '请输入用户名', text:this.searchUsername})
          .onChange((value) => {
            this.searchUsername = value;
          })
          .margin({ bottom: 10 })
          .width('90%')

        TextInput({ placeholder: '请输入操作内容', text:this.searchOperation})
          .onChange((value) => {
            this.searchOperation = value;
          })
          .margin({ bottom: 10 })
          .width('90%')

        Row() {
          Button('查询').onClick(() => this.handleSearch())
          Button('重置').onClick(() => this.handleReset()).margin({ left: 20 })
        }
        .margin({ bottom: 20 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .padding({top:20})
      .backgroundColor(Color.White)
      .borderRadius(15)
      .shadow({ radius: 6, color: '#1F000000', offsetX: 2, offsetY: 4 })
      .margin({bottom: 15})


      // 列表区域
      List({ space: 10 }) {
        if (this.loading) {
          ListItem() {
            LoadingProgress().width(50).margin({ top: 50 })
          }
        } else {
          ForEach(this.logs, (log: LogModel) => {
            ListItem() {
              Column() {
                Row() {
                  Text(`ID: ${log.id}`).fontWeight(FontWeight.Bold)
                  Text(`用户: ${log.username}`).margin({ left: 10 })
                }.width('100%').justifyContent(FlexAlign.Start)

                Text(`操作: ${log.operation}`).width('100%').margin({ top: 5 })
                Text(`IP: ${log.ipAddress}`).width('100%').margin({ top: 5 })
                Text(`时间: ${log.createdAt}`).width('100%').fontColor(Color.Gray).fontSize(12).margin({ top: 5 })

                Row() {
                  Button('删除')
                    .type(ButtonType.Capsule)
                    .backgroundColor(Color.Red)
                    .onClick(() => this.handleDelete(log.id))
                }.width('100%').justifyContent(FlexAlign.End).margin({ top: 10 })
              }
              .padding(15)
              .backgroundColor(Color.White)
              .borderRadius(10)
              .shadow({ radius: 3, color: '#1F000000' })
            }
          })
        }
      }
      .layoutWeight(1)
      .width('100%')

      // 分页
      Row({ space: 10 }) {
        Button('上一页')
          .enabled(this.pageNo > 1)
          .onClick(() => {
            this.pageNo--;
            this.fetchLogs();
          })

        Text(`${this.pageNo} / ${Math.ceil(this.total / this.pageSize)}`)

        Button('下一页')
          .enabled(this.pageNo * this.pageSize < this.total)
          .onClick(() => {
            this.pageNo++;
            this.fetchLogs();
          })
      }
      .padding(10)
      .justifyContent(FlexAlign.Center)
      .width('100%')

    }
    .width('100%')
    .height('100%')
    .padding({ left: 15, right: 15, top: 20, bottom: 10 })
    .backgroundColor('#F1F3F5')
  }
}