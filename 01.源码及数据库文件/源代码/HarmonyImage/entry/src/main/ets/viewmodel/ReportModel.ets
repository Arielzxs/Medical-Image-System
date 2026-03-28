export class Report {
  id: number | null = null;
  imageId: number;
  diagnosis: string = '';
  suggestion: string = '';
  content: string = '';
  generatedBy: number;
  createdAt: string | null = null;

  constructor(imageId: number, generatedBy: number) {
    this.imageId = imageId;
    this.generatedBy = generatedBy;
  }
}