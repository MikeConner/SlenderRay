# == Schema Information
#
# Table name: process_timers
#
#  id               :integer         not null, primary key
#  process_state    :string(16)      default("Idle"), not null
#  start_time       :datetime
#  elapsed_seconds  :integer
#  process_id       :integer
#  process_type     :string(255)
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  duration_seconds :integer
#

# CHARTER
#   Encapsulate timer logic; timers can be started, paused, and resumed. They expire, and can be marked "Completed" when expired.
#
# USAGE
#   This is a polymorphic model that can be associated with either machines or treatment areas
#
# NOTES AND WARNINGS
#
class ProcessTimer < ActiveRecord::Base
  MAX_STATE_LEN = 16
  
  IDLE = 'Idle'
  STARTED = 'Started'
  PAUSED = 'Paused'
  RESUMED = 'Resumed'
  EXPIRED = 'Expired'
  COMPLETED = 'Completed'
  
  PROCESS_STATES = [IDLE, STARTED, PAUSED, RESUMED, EXPIRED, COMPLETED]  
  
  attr_accessible :process_state, :duration_seconds, :start_time, :elapsed_seconds

  # Timers can be attached to rooms or treatments
  belongs_to :process, :dependent => :destroy, :polymorphic => true

  validates :process_state, :presence => true,
                            :inclusion => { in: PROCESS_STATES }
  validates :elapsed_seconds, :numericality => { only_integer: true, greater_than_or_equal_to: 0 },
                           :allow_nil => true
  validates_presence_of :duration_seconds
  
  # Text form of the current status, for the dashboard view
  def display_status
    s = seconds_remaining
    if s.nil?
      self.process_state
    else
      min= (s/60).floor
      sec = s - min*60;
      time = sprintf("%d:%02d", min, sec)
      "#{self.process_state}: #{time}"
    end
  end
  
  def startable?
    IDLE == self.process_state
  end
  
  def start
    if startable?
      self.process_state = STARTED
      self.start_time = Time.now
      self.save!
    end
  end
  
  def pausable?
    (STARTED == self.process_state) or (RESUMED == self.process_state)
  end
  
  def pause
    if pausable?
      self.process_state = PAUSED
      latest_elapsed = (Time.now - self.start_time).round
      self.elapsed_seconds = self.elapsed_seconds.nil? ? latest_elapsed : self.elapsed_seconds + latest_elapsed
      self.save!
    end
  end
  
  def resumable?
    PAUSED == self.process_state
  end
  
  def resume
    if resumable?
      self.process_state = RESUMED
      self.start_time = Time.now
      self.save!
    end
  end
  
  def reset
    self.process_state = IDLE
    self.start_time = nil
    self.elapsed_seconds = nil
    self.save!
  end
  
  def expireable?
    (STARTED == self.process_state) or (RESUMED == self.process_state)
  end
  
  def expire
    if expireable?
      self.process_state = EXPIRED
      self.save!
    end
  end
  
  def completeable?
    EXPIRED == self.process_state
  end
  
  def complete
    if completeable?
      self.process_state = COMPLETED
      self.save!
    end
  end
  
  # Report in seconds, or return nil; ensure never return < 0 (e.g., rounding error)
  def seconds_remaining
    case self.process_state
    when IDLE, EXPIRED, COMPLETED
      nil
    when STARTED
      [0, self.duration_seconds - (Time.now - self.start_time).round].max
    when PAUSED
      [0, self.duration_seconds - self.elapsed_seconds].max
    when RESUMED
      [0, self.duration_seconds - (Time.now - self.start_time).round - self.elapsed_seconds].max
    end
  end
end
