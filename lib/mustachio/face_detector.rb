module Mustachio
  class FaceDetector
    class << self
      def dims file
        `identify -format "%wx%h" #{file.path}`.strip.split('x').map(&:to_f)
      end

      def landmark_to_pct(landmark, width, height)
        {
          'x' => ((landmark.x / width) * 100.0),
          'y' => ((landmark.y / height) * 100.0)
        }
      end

      def run(file)
        detector = FaceDetect.new(
          file: file,
          adapter: FaceDetect::Adapter::Google
        )
        results = detector.run
        width, height = self.dims file

        results.map do |face|
          {
            'mouth_left' => landmark_to_pct(face.mouth_left, width, height),
            'mouth_center' => landmark_to_pct(face.mouth_center, width, height),
            'mouth_right' => landmark_to_pct(face.mouth_right, width, height),
            'nose' => landmark_to_pct(face.nose_bottom_center, width, height)
          }
        end
      end
    end
  end
end
