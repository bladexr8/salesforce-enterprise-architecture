import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = ['Race__c.Race_Summary__c'];

export default class RaceMarkdownViewer extends LightningElement {
  @api recordId;

  race;
  error;
  renderedMarkdown = '';

  @wire(getRecord, { recordId: '$recordId', fields: FIELDS})
  wiredRace({ error, data }) {
    if (data) {
      this.race = data;
      this.error = undefined;
      console.log(`Race Summary = ${this.race.fields.Race_Summary__c.value}`);
      const markdownContent = this.race.fields.Race_Summary__c.value;
      if (markdownContent) {
        this.renderedMarkdown = this.convertMarkdownToHtml(markdownContent);
      } else {
        this.renderedMarkdown = '<p><em>No race summary available</em></p>';
      }
    } else if (error) {
      this.error = error;
      this.race = undefined;
      this.showErrorToast();
    }
}

  convertMarkdownToHtml(markdown) {
        if (!markdown) return '';
        
        let html = markdown;
        
        // Headers (must be processed first)
        html = html.replace(/^### (.*$)/gim, '<h3>$1</h3>');
        html = html.replace(/^## (.*$)/gim, '<h2>$1</h2>');
        html = html.replace(/^# (.*$)/gim, '<h1>$1</h1>');
        
        // Bold
        html = html.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
        html = html.replace(/__(.*?)__/g, '<strong>$1</strong>');
        
        // Italic
        html = html.replace(/\*(.*?)\*/g, '<em>$1</em>');
        html = html.replace(/_(.*?)_/g, '<em>$1</em>');
        
        // Code blocks (must be processed before inline code)
        html = html.replace(/```([\s\S]*?)```/g, '<pre><code>$1</code></pre>');
        
        // Inline code
        html = html.replace(/`(.*?)`/g, '<code>$1</code>');
        
        // Links
        html = html.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" target="_blank" rel="noopener noreferrer">$1</a>');
        
        // Unordered lists
        html = html.replace(/^\* (.+$)/gim, '<li>$1</li>');
        html = html.replace(/^- (.+$)/gim, '<li>$1</li>');
        
        // Ordered lists
        html = html.replace(/^\d+\. (.+$)/gim, '<li>$1</li>');
        
        // Wrap consecutive list items in ul/ol tags
        html = html.replace(/(<li>.*<\/li>)/gs, (match) => {
            // Simple heuristic: if it contains numbered items, use ol, otherwise ul
            const hasNumbers = markdown.match(/^\d+\./gm);
            const tag = hasNumbers ? 'ol' : 'ul';
            return `<${tag}>${match}</${tag}>`;
        });
        
        // Blockquotes
        html = html.replace(/^> (.+$)/gim, '<blockquote>$1</blockquote>');
        
        // Horizontal rules
        html = html.replace(/^---$/gim, '<hr>');
        html = html.replace(/^\*\*\*$/gim, '<hr>');
        
        // Line breaks and paragraphs
        html = html.replace(/\n\n/g, '</p><p>');
        html = html.replace(/\n/g, '<br>');
        
        // Wrap in paragraph tags if not already wrapped in block elements
        if (!html.match(/^<(h[1-6]|div|p|ul|ol|blockquote|pre)/)) {
            html = '<p>' + html + '</p>';
        }
        
        // Clean up empty paragraphs
        html = html.replace(/<p><\/p>/g, '');
        html = html.replace(/<p>\s*<\/p>/g, '');
        
        return html;
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error loading race summary',
            message: 'There was an error loading the race summary content.',
            variant: 'error',
        });
        this.dispatchEvent(event);
    }

    get hasContent() {
        return this.renderedMarkdown && this.renderedMarkdown.trim() !== '';
    }

}