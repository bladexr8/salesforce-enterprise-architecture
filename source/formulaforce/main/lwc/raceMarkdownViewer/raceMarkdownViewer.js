import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = ['Race__c.Race_Summary__c'];

export default class RaceMarkdownViewer extends LightningElement {
    @api recordId;
    
    race;
    error;
    renderedMarkdown = '';

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRace({ error, data }) {
        if (data) {
            this.race = data;
            this.error = undefined;
            console.log('Race data received:', data);
            
            const markdownContent = this.race.fields.Race_Summary__c.value;
            console.log('Markdown content:', markdownContent);
            
            if (markdownContent) {
                this.renderedMarkdown = this.convertMarkdownToHtml(markdownContent);
                console.log('Rendered HTML:', this.renderedMarkdown);
            } else {
                this.renderedMarkdown = '<p><em>No race summary available</em></p>';
            }
        } else if (error) {
            this.error = error;
            this.race = undefined;
            console.error('Error loading race data:', error);
            this.showErrorToast();
        }
    }

    convertMarkdownToHtml(markdown) {
        if (!markdown) return '';
        
        let html = markdown;
        
        // Headers (must be processed first)
        html = html.replace(/^### (.*$)/gim, '<br /><br /><h3>$1</h3>');
        html = html.replace(/^## (.*$)/gim, '<br /><br /><h2>$1</h2>');
        html = html.replace(/^# (.*$)/gim, '<br /><br /><h1>$1</h1>');
        
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
        
        // Strikethrough
        html = html.replace(/~~(.*?)~~/g, '<del>$1</del>');
        
        // Horizontal rules (before processing line breaks)
        html = html.replace(/^---$/gim, '<hr>');
        html = html.replace(/^\*\*\*$/gim, '<hr>');
        
        // Process lists
        html = this.processLists(html);
        
        // Blockquotes
        html = html.replace(/^> (.+$)/gim, '<blockquote>$1</blockquote>');
        
        // Convert double line breaks to paragraph breaks
        html = html.replace(/\n\s*\n/g, '</p><p>');
        
        // Convert single line breaks to <br> tags
        html = html.replace(/\n/g, '<br>');
        
        // Wrap in paragraph tags if not already wrapped in block elements
        if (!html.match(/^<(h[1-6]|div|p|ul|ol|blockquote|pre|hr)/)) {
            html = '<p>' + html + '</p>';
        }
        
        // Clean up empty paragraphs and extra breaks
        html = html.replace(/<p><\/p>/g, '');
        html = html.replace(/<p>\s*<\/p>/g, '');
        html = html.replace(/<br\s*\/?>\s*<\/p>/g, '</p>');
        html = html.replace(/<p>\s*<br\s*\/?>/g, '<p>');
        
        return html;
    }

    processLists(html) {
        // Split into lines for processing
        const lines = html.split('\n');
        const result = [];
        let inUnorderedList = false;
        let inOrderedList = false;
        
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const unorderedMatch = line.match(/^[\*\-\+]\s+(.+)$/);
            const orderedMatch = line.match(/^\d+\.\s+(.+)$/);
            
            if (unorderedMatch) {
                if (!inUnorderedList) {
                    if (inOrderedList) {
                        result.push('</ol>');
                        inOrderedList = false;
                    }
                    result.push('<ul>');
                    inUnorderedList = true;
                }
                result.push(`<li>${unorderedMatch[1]}</li>`);
            } else if (orderedMatch) {
                if (!inOrderedList) {
                    if (inUnorderedList) {
                        result.push('</ul>');
                        inUnorderedList = false;
                    }
                    result.push('<ol>');
                    inOrderedList = true;
                }
                result.push(`<li>${orderedMatch[1]}</li>`);
            } else {
                if (inUnorderedList) {
                    result.push('</ul>');
                    inUnorderedList = false;
                }
                if (inOrderedList) {
                    result.push('</ol>');
                    inOrderedList = false;
                }
                result.push(line);
            }
        }
        
        // Close any remaining lists
        if (inUnorderedList) {
            result.push('</ul>');
        }
        if (inOrderedList) {
            result.push('</ol>');
        }
        
        return result.join('\n');
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
        return this.renderedMarkdown && this.renderedMarkdown.trim() !== '' && this.renderedMarkdown !== '<p><em>No race summary available</em></p>';
    }
}