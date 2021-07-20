;;; inferior-maple-mode.el --- Inferior Maple mode   -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Juan M. Bello-Rivas

;; Author: Juan M. Bello-Rivas <jmbr@superadditive.com>
;; Keywords: languages, processes

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This file defines a simple comint-based interface to Maple.

;;; Code:

(require 'comint)

(defgroup inferior-maple nil
  "Inferior Maple mode."
  :group 'processes)

(defcustom inferior-maple-program "maple"
  "Name of the Maple executable."
  :type 'string
  :group 'inferior-maple)

(defcustom inferior-maple-prompt "^> "
  "Regular expression to match the Maple prompt."
  :type 'string
  :group 'inferior-maple)

(defcustom inferior-maple-init-string "interface(ansi=false, screenheight=infinity):"
  "Command string to send to Maple when it starts."
  :type 'string
  :group 'inferior-maple)

(defvar inferior-maple-buffer nil
  "Current inferior-maple buffer.")

(defvar inferior-maple-process nil
  "Current inferior-maple process.")

(defvar inferior-maple-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-a" 'comint-bol)
    map)
  "Keymap used in inferior Maple mode.")

(define-derived-mode inferior-maple-mode comint-mode "maple"
  "Inferior Maple"
  (setq comint-process-echoes t
        comint-prompt-regexp inferior-maple-prompt
        comint-prompt-read-only t
        mode-line-process '(":%s")))

(defun inferior-maple-buffer-live-p ()
  "Determine whether an inferior Maple buffer is usable."
  (and inferior-maple-buffer
       (buffer-live-p inferior-maple-buffer)))

(defun inferior-maple ()
  "Run inferior Maple process."
  (interactive)
  (if (and (inferior-maple-buffer-live-p)
           (get-buffer-process inferior-maple-buffer))
      (pop-to-buffer inferior-maple-buffer)
    (progn
      (setq inferior-maple-buffer (make-comint "maple" inferior-maple-program)
            inferior-maple-process (get-buffer-process inferior-maple-buffer))
      (switch-to-buffer inferior-maple-buffer)
      (inferior-maple-mode)
      (when inferior-maple-init-string
        (comint-simple-send inferior-maple-process inferior-maple-init-string)))))

(defalias 'run-maple 'inferior-maple)

(defun switch-to-maple (eob-p)
  "Switch to the inferior Maple process buffer.
If EOB-P is not NIL, the cursor is moved to the end of buffer."
  (interactive "P")
  (if (inferior-maple-buffer-live-p)
      (pop-to-buffer inferior-maple-buffer)
    (run-maple))
  (when eob-p
    (push-mark)
    (goto-char (point-max))))

(defun maple-send-region (start end &optional and-go)
  "Send the current region to the inferior Maple process.
The arguments START and END delimit the region to be sent.
If AND-GO is not NIL, then switch to the Maple buffer."
  (interactive "r\nP")
  (comint-send-region inferior-maple-process start end)
  (comint-send-string inferior-maple-process "\n")
  (if and-go (switch-to-maple t)))

(defun maple-send-buffer (&optional and-go)
  "Send the current buffer to the inferior Maple process.
If AND-GO is not NIL, then switch to the Maple buffer."
  (interactive "P")
  (maple-send-region (point-min) (point-max) and-go))

(provide 'inferior-maple-mode)

;;; inferior-maple-mode.el ends here
