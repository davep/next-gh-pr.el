;;; next-gh-pr.el --- Insert the next likely GitHub PR number -*- lexical-binding: t -*-
;; Copyright 2026 by Dave Pearson <davep@davep.org>

;; Author: Dave Pearson <davep@davep.org>
;; Version: 1.0.0
;; Keywords: convenience
;; URL: https://github.com/davep/next-gh-pr.el
;; Package-Requires: ((emacs "26.1"))

;; This program is free software: you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the
;; Free Software Foundation, either version 3 of the License, or (at your
;; option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
;; Public License for more details.
;;
;; You should have received a copy of the GNU General Public License along
;; with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; next-gh-pr.el provides a command for estimating and inserting the next
;; likely GitHub PR number for a given repository.

;;; Code:

(defun next-gh-pr--get-url ()
  "Return the URL of the current repository.

Throws an error if this isn't a GitHub repository."
  (unless (executable-find "gh")
    (error "The 'gh' command-line tool is not installed or not in PATH"))
  (let ((remote-url (string-trim (shell-command-to-string "gh repo view --json url --jq '.url' 2>/dev/null"))))
    (if (string-empty-p remote-url)
        (error "Not a GitHub repository"))
      remote-url))

(defun next-gh-pr--latest-number (type)
  "Return the number of the latest TYPE of item on GitHub."
  (or (when-let (result
                 (shell-command-to-string
                  (format "gh %s list --state all --limit 1 --json number --jq '.[0].number'" type)))
        (string-to-number (string-trim result)))
      0))

(defun next-gh-pr-insert-markdown-link ()
  "Insert a markdown link to the next likely GitHub PR number."
  (interactive)
  (let* ((url (next-gh-pr--get-url))
         (next-number (1+ (max (next-gh-pr--latest-number "pr") (next-gh-pr--latest-number "issue")))))
    (insert (format "[#%1$d](%s/pull/%1$d)" next-number url))))

(provide 'next-gh-pr)

;;; next-gh-pr.el ends here
